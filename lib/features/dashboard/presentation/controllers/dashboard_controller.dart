import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:landing_groom_page/features/dashboard/data/datasources/firebase_dashboard_datasource.dart';
import 'package:landing_groom_page/features/dashboard/data/repositories/firebase_dashboard_repository_impl.dart';
import 'package:landing_groom_page/features/dashboard/data/repositories/in_memory_dashboard_repository.dart';
import 'package:landing_groom_page/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:landing_groom_page/features/dashboard/domain/repositories/dashboard_repository.dart';

final groomeDashboardStore = DashboardController(
  repositoryFactory: createDashboardRepository,
);

DashboardRepository createDashboardRepository() {
  if (Firebase.apps.isEmpty) {
    return InMemoryDashboardRepository.seeded();
  }
  return FirebaseDashboardRepositoryImpl(FirebaseDashboardDatasource());
}

class DashboardController extends ChangeNotifier {
  DashboardController({
    required DashboardRepository Function() repositoryFactory,
  }) : _repositoryFactory = repositoryFactory;

  final DashboardRepository Function() _repositoryFactory;
  DashboardRepository? _repository;

  final _subscriptions = <StreamSubscription<void>>[];
  StreamSubscription<List<SalonProfile>>? _salonsSubscription;
  StreamSubscription<List<TeamMember>>? _teamSubscription;
  StreamSubscription<List<ServiceItem>>? _servicesSubscription;
  StreamSubscription<List<BookingItem>>? _bookingsSubscription;
  StreamSubscription<List<ClientProfile>>? _clientsSubscription;

  final List<DashboardUser> _users = [];
  final List<SalonProfile> _salons = [];
  final List<TeamMember> _team = [];
  final List<ServiceItem> _services = [];
  final List<BookingItem> _bookings = [];
  final List<ClientProfile> _clients = [];

  bool _initializing = false;
  bool _authChecked = false;

  DashboardUser? currentUser;

  bool get authChecked => _authChecked;

  String get today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  String get tomorrow => DateFormat(
    'yyyy-MM-dd',
  ).format(DateTime.now().add(const Duration(days: 1)));

  List<DashboardUser> get users => List.unmodifiable(_users);

  List<SalonProfile> get visibleSalons {
    final user = currentUser;
    if (user == null) return const [];
    if (user.role == DashboardRole.superAdmin) {
      return List.unmodifiable(_salons);
    }
    return _salons.where((salon) => salon.ownerUserId == user.id).toList();
  }

  Future<void> initialize() async {
    if (_initializing || _authChecked) return;
    _initializing = true;
    _repository ??= _repositoryFactory();

    final user = await _repository!.currentUser();
    if (user != null &&
        (user.role == DashboardRole.superAdmin || user.subscriptionActive)) {
      _startSession(user);
    } else if (user != null) {
      await _repository!.signOut();
      _clearSession();
    }

    _authChecked = true;
    _initializing = false;
    notifyListeners();
  }

  Future<DashboardLoginResult> signIn(String email, String password) async {
    _repository ??= _repositoryFactory();
    final result = await _repository!.signIn(email, password);
    if (result.success && result.user != null) {
      _authChecked = true;
      _startSession(result.user!);
    }
    return result;
  }

  Future<void> logout() async {
    await _repository?.signOut();
    _clearSession();
    _authChecked = true;
    notifyListeners();
  }

  bool emailExists(String email) =>
      _users.any((user) => user.email.toLowerCase() == email.toLowerCase());

  Future<void> createAdmin({
    required String name,
    required String email,
    required String password,
    required String salonName,
  }) async {
    await _repository?.createAdmin(
      name: name,
      email: email,
      password: password,
      salonName: salonName,
    );
  }

  Future<void> updatePassword(String userId, String password) async {
    await _repository?.updatePassword(userId, password);
  }

  Future<void> toggleSubscription(String userId) async {
    final user = _userById(userId);
    if (user == null || user.role == DashboardRole.superAdmin) return;
    await _repository?.setSubscription(userId, !user.subscriptionActive);
  }

  Future<void> deleteUser(String userId) async {
    final user = _userById(userId);
    if (user == null || user.role == DashboardRole.superAdmin) return;
    await _repository?.deleteUser(userId);
  }

  Future<void> addSalon({
    required String ownerUserId,
    required String name,
    required String locality,
    required String address,
    required String phone,
    required String email,
  }) async {
    await _repository?.addSalon(
      ownerUserId: ownerUserId,
      name: name,
      locality: locality,
      address: address,
      phone: phone,
      email: email,
    );
  }

  Future<void> updateSalon(SalonProfile updated) async {
    await _repository?.updateSalon(updated);
  }

  Future<void> toggleSalonBookings(String salonId) async {
    final salon = salonById(salonId);
    if (salon == null) return;
    await _repository?.setSalonBookings(salonId, !salon.acceptingBookings);
  }

  Future<void> addTeamMember({
    required String salonId,
    required String name,
    required String role,
    required String experience,
  }) async {
    await _repository?.addTeamMember(
      salonId: salonId,
      name: name,
      role: role,
      experience: experience,
    );
  }

  Future<void> toggleTeamMember(String memberId) async {
    final member = teamById(memberId);
    if (member == null) return;
    await _repository?.setTeamMemberActive(memberId, !member.active);
  }

  Future<void> removeTeamMember(String memberId) async {
    await _repository?.removeTeamMember(memberId);
  }

  Future<void> addService({
    required String salonId,
    required String name,
    required String category,
    required int durationMinutes,
    required int price,
    required List<String> teamMemberIds,
  }) async {
    await _repository?.addService(
      salonId: salonId,
      name: name,
      category: category,
      durationMinutes: durationMinutes,
      price: price,
      teamMemberIds: teamMemberIds,
    );
  }

  Future<void> removeService(String serviceId) async {
    await _repository?.removeService(serviceId);
  }

  Future<void> addBooking({
    required String salonId,
    required String customerName,
    required String customerPhone,
    required String serviceId,
    required String teamMemberId,
    required String date,
    required String time,
    required String source,
  }) async {
    await _repository?.addBooking(
      salonId: salonId,
      customerName: customerName,
      customerPhone: customerPhone,
      serviceId: serviceId,
      teamMemberId: teamMemberId,
      date: date,
      time: time,
      source: source,
      servicePrice: serviceById(serviceId)?.price ?? 0,
    );
  }

  Future<void> cancelBooking(String bookingId) async {
    await _repository?.cancelBooking(bookingId);
  }

  List<TeamMember> teamFor(String? salonId) =>
      _team.where((member) => member.salonId == salonId).toList();

  List<ServiceItem> servicesFor(String? salonId) =>
      _services.where((service) => service.salonId == salonId).toList();

  List<BookingItem> bookingsFor(String? salonId) =>
      _bookings.where((booking) => booking.salonId == salonId).toList();

  List<ClientProfile> clientsFor(String? salonId) =>
      _clients.where((client) => client.salonId == salonId).toList();

  SalonProfile? salonById(String id) {
    for (final salon in _salons) {
      if (salon.id == id) return salon;
    }
    return null;
  }

  TeamMember? teamById(String id) {
    for (final member in _team) {
      if (member.id == id) return member;
    }
    return null;
  }

  ServiceItem? serviceById(String id) {
    for (final service in _services) {
      if (service.id == id) return service;
    }
    return null;
  }

  BookingItem? bookingById(String id) {
    for (final booking in _bookings) {
      if (booking.id == id) return booking;
    }
    return null;
  }

  void _startSession(DashboardUser user) {
    currentUser = user;
    _subscribeUserStream(user);
    _subscribeSalonStream(user);
    notifyListeners();
  }

  void _subscribeUserStream(DashboardUser user) {
    _subscriptions.add(
      _repository!.watchUsers(user).listen((users) {
        _users
          ..clear()
          ..addAll(users);
        final latest = _userById(user.id);
        if (latest != null) {
          currentUser = latest;
          if (latest.role != DashboardRole.superAdmin &&
              !latest.subscriptionActive) {
            logout();
            return;
          }
        }
        notifyListeners();
      }),
    );
  }

  void _subscribeSalonStream(DashboardUser user) {
    _salonsSubscription?.cancel();
    _salonsSubscription = _repository!.watchSalons(user).listen((salons) {
      _salons
        ..clear()
        ..addAll(salons);
      _subscribeSalonCollections(user, salons.map((salon) => salon.id).toSet());
      notifyListeners();
    });
  }

  void _subscribeSalonCollections(DashboardUser user, Set<String> salonIds) {
    _teamSubscription?.cancel();
    _servicesSubscription?.cancel();
    _bookingsSubscription?.cancel();
    _clientsSubscription?.cancel();

    _teamSubscription = _repository!.watchTeam(user, salonIds).listen((team) {
      _team
        ..clear()
        ..addAll(team);
      notifyListeners();
    });
    _servicesSubscription = _repository!.watchServices(user, salonIds).listen((
      services,
    ) {
      _services
        ..clear()
        ..addAll(services);
      notifyListeners();
    });
    _bookingsSubscription = _repository!.watchBookings(user, salonIds).listen((
      bookings,
    ) {
      _bookings
        ..clear()
        ..addAll(bookings);
      notifyListeners();
    });
    _clientsSubscription = _repository!.watchClients(user, salonIds).listen((
      clients,
    ) {
      _clients
        ..clear()
        ..addAll(clients);
      notifyListeners();
    });
  }

  DashboardUser? _userById(String id) {
    for (final user in _users) {
      if (user.id == id) return user;
    }
    if (currentUser?.id == id) return currentUser;
    return null;
  }

  void _clearSession() {
    currentUser = null;
    _users.clear();
    _salons.clear();
    _team.clear();
    _services.clear();
    _bookings.clear();
    _clients.clear();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _salonsSubscription?.cancel();
    _teamSubscription?.cancel();
    _servicesSubscription?.cancel();
    _bookingsSubscription?.cancel();
    _clientsSubscription?.cancel();
  }
}
