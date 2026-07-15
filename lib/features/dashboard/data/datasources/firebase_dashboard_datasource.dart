import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:landing_groom_page/features/dashboard/domain/entities/dashboard_entities.dart';

class FirebaseDashboardDatasource {
  FirebaseDashboardDatasource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'asia-south1');

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  String? get currentAuthUid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('dashboard_users');

  CollectionReference<Map<String, dynamic>> get _salons =>
      _firestore.collection('salons');

  CollectionReference<Map<String, dynamic>> get _team =>
      _firestore.collection('team_members');

  CollectionReference<Map<String, dynamic>> get _services =>
      _firestore.collection('services');

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _firestore.collection('bookings');

  CollectionReference<Map<String, dynamic>> get _clients =>
      _firestore.collection('clients');

  Future<DashboardLoginResult> signIn(String email, String password) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final currentUser = _auth.currentUser;
      if (currentUser != null &&
          currentUser.email?.toLowerCase() == normalizedEmail) {
        return _loginResultForUid(currentUser.uid);
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        return const DashboardLoginResult(
          success: false,
          message: 'Email or password is incorrect.',
        );
      }

      return _loginResultForUid(uid);
    } on FirebaseAuthException catch (error) {
      return DashboardLoginResult(success: false, message: _authMessage(error));
    } catch (_) {
      return const DashboardLoginResult(
        success: false,
        message: 'Unable to login right now. Please try again.',
      );
    }
  }

  Future<DashboardLoginResult> _loginResultForUid(String uid) async {
    final user = await dashboardUser(uid);
    if (user == null) {
      await _auth.signOut();
      return const DashboardLoginResult(
        success: false,
        message: 'Dashboard account is not set up. Please contact Super Admin.',
      );
    }

    if (user.role != DashboardRole.superAdmin && !user.subscriptionActive) {
      await _auth.signOut();
      return const DashboardLoginResult(
        success: false,
        message:
            'Your subscription is stopped. Please contact with Super Admin.',
      );
    }

    return DashboardLoginResult(success: true, user: user);
  }

  Future<DashboardUser?> dashboardUser(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists) return null;
    return _userFromDoc(snapshot);
  }

  Future<void> signOut() => _auth.signOut();

  Stream<List<DashboardUser>> watchUsers(DashboardUser user) {
    if (user.role == DashboardRole.superAdmin) {
      return _users.snapshots().map(
        (snapshot) => snapshot.docs.map(_userFromDoc).toList(),
      );
    }
    return _users.doc(user.id).snapshots().map((snapshot) {
      if (!snapshot.exists) return <DashboardUser>[];
      return [_userFromDoc(snapshot)];
    });
  }

  Stream<List<SalonProfile>> watchSalons(DashboardUser user) {
    final query = user.role == DashboardRole.superAdmin
        ? _salons
        : _salons.where('ownerUserId', isEqualTo: user.id);
    return query.snapshots().map(
      (snapshot) => snapshot.docs.map(_salonFromDoc).toList(),
    );
  }

  Stream<List<TeamMember>> watchTeam(
    DashboardUser user,
    Set<String> salonIds,
  ) => _watchSalonCollection(
    user: user,
    salonIds: salonIds,
    collection: _team,
    mapper: _teamFromDoc,
  );

  Stream<List<ServiceItem>> watchServices(
    DashboardUser user,
    Set<String> salonIds,
  ) => _watchSalonCollection(
    user: user,
    salonIds: salonIds,
    collection: _services,
    mapper: _serviceFromDoc,
  );

  Stream<List<BookingItem>> watchBookings(
    DashboardUser user,
    Set<String> salonIds,
  ) => _watchSalonCollection(
    user: user,
    salonIds: salonIds,
    collection: _bookings,
    mapper: _bookingFromDoc,
  );

  Stream<List<ClientProfile>> watchClients(
    DashboardUser user,
    Set<String> salonIds,
  ) => _watchSalonCollection(
    user: user,
    salonIds: salonIds,
    collection: _clients,
    mapper: _clientFromDoc,
  );

  Future<void> createAdmin({
    required String name,
    required String email,
    required String password,
    required String salonName,
  }) async {
    await _refreshAuthToken();
    await _functions.httpsCallable('createDashboardAdmin').call({
      'name': name,
      'email': email,
      'password': password,
      'salonName': salonName,
    });
  }

  Future<void> updatePassword(String userId, String password) async {
    await _refreshAuthToken();
    await _functions.httpsCallable('setDashboardUserPassword').call({
      'userId': userId,
      'password': password,
    });
  }

  Future<void> setSubscription(String userId, bool active) async {
    await _refreshAuthToken();
    await _functions.httpsCallable('setDashboardSubscription').call({
      'userId': userId,
      'subscriptionActive': active,
    });
  }

  Future<void> deleteUser(String userId) async {
    await _refreshAuthToken();
    await _functions.httpsCallable('deleteDashboardUser').call({
      'userId': userId,
    });
  }

  Future<void> _refreshAuthToken() async {
    await _auth.currentUser?.getIdToken(true);
  }

  Future<void> addSalon({
    required String ownerUserId,
    required String name,
    required String locality,
    required String address,
    required String phone,
    required String email,
  }) async {
    await _salons.add({
      'ownerUserId': ownerUserId,
      'name': name,
      'locality': locality,
      'address': address,
      'phone': phone,
      'email': email,
      'about': 'New branch added to Groome.',
      'openingTime': '10:00 AM',
      'closingTime': '08:00 PM',
      'acceptingBookings': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSalon(SalonProfile salon) async {
    await _salons.doc(salon.id).update({
      'name': salon.name,
      'locality': salon.locality,
      'address': salon.address,
      'phone': salon.phone,
      'email': salon.email,
      'about': salon.about,
      'openingTime': salon.openingTime,
      'closingTime': salon.closingTime,
      'acceptingBookings': salon.acceptingBookings,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setSalonBookings(String salonId, bool acceptingBookings) async {
    await _salons.doc(salonId).update({
      'acceptingBookings': acceptingBookings,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addTeamMember({
    required String salonId,
    required String name,
    required String role,
    required String experience,
  }) async {
    await _team.add({
      'salonId': salonId,
      'name': name,
      'role': role,
      'experience': experience,
      'workingDays': 'Mon-Sat',
      'workingHours': '10:00 AM - 07:00 PM',
      'breakTime': '02:00 PM - 02:30 PM',
      'services': <String>[],
      'active': true,
      'rating': 4.6,
      'bookingsThisMonth': 0,
      'revenue': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setTeamMemberActive(String memberId, bool active) async {
    await _team.doc(memberId).update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeTeamMember(String memberId) async {
    final services = await _services
        .where('teamMemberIds', arrayContains: memberId)
        .get();
    final batch = _firestore.batch();
    batch.delete(_team.doc(memberId));
    for (final service in services.docs) {
      batch.update(service.reference, {
        'teamMemberIds': FieldValue.arrayRemove([memberId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> addService({
    required String salonId,
    required String name,
    required String category,
    required int durationMinutes,
    required int price,
    required List<String> teamMemberIds,
  }) async {
    await _services.add({
      'salonId': salonId,
      'name': name,
      'category': category,
      'durationMinutes': durationMinutes,
      'price': price,
      'teamMemberIds': teamMemberIds,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeService(String serviceId) =>
      _services.doc(serviceId).delete();

  Future<void> addBooking({
    required String salonId,
    required String customerName,
    required String customerPhone,
    required String serviceId,
    required String teamMemberId,
    required String date,
    required String time,
    required String source,
    required int servicePrice,
  }) async {
    final bookingId =
        'GRM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final normalizedPhone = _phoneKey(customerPhone);
    final clientQuery = await _clients
        .where('salonId', isEqualTo: salonId)
        .where('phoneNormalized', isEqualTo: normalizedPhone)
        .limit(1)
        .get();

    final batch = _firestore.batch();
    batch.set(_bookings.doc(bookingId), {
      'salonId': salonId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'serviceId': serviceId,
      'teamMemberId': teamMemberId,
      'date': date,
      'time': time,
      'status': 'Confirmed',
      'source': source,
      'note': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (clientQuery.docs.isEmpty) {
      batch.set(_clients.doc(), {
        'salonId': salonId,
        'name': customerName,
        'phone': customerPhone,
        'phoneNormalized': normalizedPhone,
        'totalVisits': 1,
        'totalSpend': servicePrice,
        'lastVisit': date,
        'noShowCount': 0,
        'notes': 'Created from manual booking.',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      batch.update(clientQuery.docs.first.reference, {
        'name': customerName,
        'totalVisits': FieldValue.increment(1),
        'totalSpend': FieldValue.increment(servicePrice),
        'lastVisit': date,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> cancelBooking(String bookingId) async {
    await _bookings.doc(bookingId).update({
      'status': 'Cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<T>> _watchSalonCollection<T>({
    required DashboardUser user,
    required Set<String> salonIds,
    required CollectionReference<Map<String, dynamic>> collection,
    required T Function(QueryDocumentSnapshot<Map<String, dynamic>>) mapper,
  }) {
    if (user.role == DashboardRole.superAdmin) {
      return collection.snapshots().map(
        (snapshot) => snapshot.docs.map(mapper).toList(),
      );
    }

    if (salonIds.isEmpty) return Stream.value(<T>[]);
    final ids = salonIds.toList();
    final queries = <Query<Map<String, dynamic>>>[];
    for (var i = 0; i < ids.length; i += 30) {
      final end = i + 30 > ids.length ? ids.length : i + 30;
      queries.add(collection.where('salonId', whereIn: ids.sublist(i, end)));
    }
    return _combineQueryStreams(queries, mapper);
  }

  Stream<List<T>> _combineQueryStreams<T>(
    List<Query<Map<String, dynamic>>> queries,
    T Function(QueryDocumentSnapshot<Map<String, dynamic>>) mapper,
  ) {
    if (queries.isEmpty) return Stream.value(<T>[]);

    late StreamController<List<T>> controller;
    final partials = List<List<T>>.generate(queries.length, (_) => <T>[]);
    final subscriptions =
        <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

    controller = StreamController<List<T>>.broadcast(
      onListen: () {
        for (var i = 0; i < queries.length; i++) {
          subscriptions.add(
            queries[i].snapshots().listen((snapshot) {
              partials[i] = snapshot.docs.map(mapper).toList();
              controller.add([for (final part in partials) ...part]);
            }, onError: controller.addError),
          );
        }
      },
      onCancel: () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );

    return controller.stream;
  }

  DashboardUser _userFromDoc(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return DashboardUser(
      id: snapshot.id,
      name: _string(data, 'name', fallback: 'Groome Admin'),
      email: _string(data, 'email'),
      role: DashboardRole.fromValue(_string(data, 'role')),
      subscriptionActive: _bool(data, 'subscriptionActive', fallback: true),
      primarySalonName: _string(data, 'primarySalonName', fallback: 'Groome'),
    );
  }

  SalonProfile _salonFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return SalonProfile(
      id: snapshot.id,
      ownerUserId: _string(data, 'ownerUserId'),
      name: _string(data, 'name', fallback: 'Salon'),
      locality: _string(data, 'locality', fallback: 'New Delhi'),
      address: _string(data, 'address'),
      phone: _string(data, 'phone'),
      email: _string(data, 'email'),
      about: _string(data, 'about'),
      openingTime: _string(data, 'openingTime', fallback: '10:00 AM'),
      closingTime: _string(data, 'closingTime', fallback: '08:00 PM'),
      acceptingBookings: _bool(data, 'acceptingBookings', fallback: true),
    );
  }

  TeamMember _teamFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return TeamMember(
      id: snapshot.id,
      salonId: _string(data, 'salonId'),
      name: _string(data, 'name', fallback: 'Team Member'),
      role: _string(data, 'role', fallback: 'Stylist'),
      experience: _string(data, 'experience', fallback: '0 years'),
      workingDays: _string(data, 'workingDays', fallback: 'Mon-Sat'),
      workingHours: _string(
        data,
        'workingHours',
        fallback: '10:00 AM - 07:00 PM',
      ),
      breakTime: _string(data, 'breakTime'),
      services: _stringList(data, 'services'),
      active: _bool(data, 'active', fallback: true),
      rating: _double(data, 'rating', fallback: 4.6),
      bookingsThisMonth: _int(data, 'bookingsThisMonth'),
      revenue: _int(data, 'revenue'),
    );
  }

  ServiceItem _serviceFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return ServiceItem(
      id: snapshot.id,
      salonId: _string(data, 'salonId'),
      name: _string(data, 'name', fallback: 'Service'),
      category: _string(data, 'category', fallback: 'General'),
      durationMinutes: _int(data, 'durationMinutes', fallback: 30),
      price: _int(data, 'price'),
      teamMemberIds: _stringList(data, 'teamMemberIds'),
    );
  }

  BookingItem _bookingFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return BookingItem(
      id: snapshot.id,
      salonId: _string(data, 'salonId'),
      customerName: _string(data, 'customerName', fallback: 'Customer'),
      customerPhone: _string(data, 'customerPhone'),
      serviceId: _string(data, 'serviceId'),
      teamMemberId: _string(data, 'teamMemberId'),
      date: _string(data, 'date'),
      time: _string(data, 'time'),
      status: _string(data, 'status', fallback: 'Confirmed'),
      source: _string(data, 'source', fallback: 'Manual'),
      note: _string(data, 'note'),
    );
  }

  ClientProfile _clientFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return ClientProfile(
      id: snapshot.id,
      salonId: _string(data, 'salonId'),
      name: _string(data, 'name', fallback: 'Client'),
      phone: _string(data, 'phone'),
      totalVisits: _int(data, 'totalVisits'),
      totalSpend: _int(data, 'totalSpend'),
      lastVisit: _string(data, 'lastVisit'),
      noShowCount: _int(data, 'noShowCount'),
      notes: _string(data, 'notes'),
    );
  }

  String _authMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email or password is incorrect.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      default:
        final message = error.message;
        if (message == null ||
            message.contains('dev.flutter.pigeon') ||
            message.contains('FirebaseAuthHostApi') ||
            message.contains('channel-error')) {
          return 'Unable to reach Firebase login. Please refresh the page and try again.';
        }
        return message;
    }
  }

  String _string(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    return value is String && value.trim().isNotEmpty ? value : fallback;
  }

  bool _bool(Map<String, dynamic> data, String key, {bool fallback = false}) {
    final value = data[key];
    return value is bool ? value : fallback;
  }

  int _int(Map<String, dynamic> data, String key, {int fallback = 0}) {
    final value = data[key];
    if (value is int) return value;
    if (value is num) return value.round();
    return fallback;
  }

  double _double(Map<String, dynamic> data, String key, {double fallback = 0}) {
    final value = data[key];
    return value is num ? value.toDouble() : fallback;
  }

  List<String> _stringList(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is Iterable) {
      return value.whereType<String>().toList();
    }
    return <String>[];
  }

  String _phoneKey(String phone) => phone.replaceAll(RegExp(r'\D'), '');
}
