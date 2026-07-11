import 'dart:async';

import 'package:intl/intl.dart';
import 'package:landing_groom_page/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:landing_groom_page/features/dashboard/domain/repositories/dashboard_repository.dart';

class InMemoryDashboardRepository implements DashboardRepository {
  InMemoryDashboardRepository.seeded() {
    _seed();
    _emitAll();
  }

  final _users = <DashboardUser>[];
  final _salons = <SalonProfile>[];
  final _team = <TeamMember>[];
  final _services = <ServiceItem>[];
  final _bookings = <BookingItem>[];
  final _clients = <ClientProfile>[];
  final _passwords = <String, String>{};

  final _usersController = StreamController<List<DashboardUser>>.broadcast();
  final _salonsController = StreamController<List<SalonProfile>>.broadcast();
  final _teamController = StreamController<List<TeamMember>>.broadcast();
  final _servicesController = StreamController<List<ServiceItem>>.broadcast();
  final _bookingsController = StreamController<List<BookingItem>>.broadcast();
  final _clientsController = StreamController<List<ClientProfile>>.broadcast();

  DashboardUser? _currentUser;

  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  String get _tomorrow => DateFormat(
    'yyyy-MM-dd',
  ).format(DateTime.now().add(const Duration(days: 1)));

  @override
  String? get currentAuthUid => _currentUser?.id;

  @override
  Future<DashboardLoginResult> signIn(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final match = _users.where(
      (user) =>
          user.email.toLowerCase() == normalizedEmail &&
          _passwords[user.id] == password,
    );

    if (match.isEmpty) {
      return const DashboardLoginResult(
        success: false,
        message: 'Email or password is incorrect.',
      );
    }

    final user = match.first;
    if (user.role != DashboardRole.superAdmin && !user.subscriptionActive) {
      return const DashboardLoginResult(
        success: false,
        message:
            'Your subscription is stopped. Please contact with Super Admin.',
      );
    }

    _currentUser = user;
    return DashboardLoginResult(success: true, user: user);
  }

  @override
  Future<DashboardUser?> currentUser() async => _currentUser;

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Stream<List<DashboardUser>> watchUsers(DashboardUser user) {
    Future.microtask(_emitAll);
    return _usersController.stream.map((users) {
      if (user.role == DashboardRole.superAdmin) return users;
      return users.where((candidate) => candidate.id == user.id).toList();
    });
  }

  @override
  Stream<List<SalonProfile>> watchSalons(DashboardUser user) {
    Future.microtask(_emitAll);
    return _salonsController.stream.map((salons) {
      if (user.role == DashboardRole.superAdmin) return salons;
      return salons.where((salon) => salon.ownerUserId == user.id).toList();
    });
  }

  @override
  Stream<List<TeamMember>> watchTeam(
    DashboardUser user,
    Set<String> salonIds,
  ) => _teamController.stream.map(
    (team) => _filterBySalon(
      user: user,
      salonIds: salonIds,
      items: team,
      salonId: (item) => item.salonId,
    ),
  );

  @override
  Stream<List<ServiceItem>> watchServices(
    DashboardUser user,
    Set<String> salonIds,
  ) => _servicesController.stream.map(
    (services) => _filterBySalon(
      user: user,
      salonIds: salonIds,
      items: services,
      salonId: (item) => item.salonId,
    ),
  );

  @override
  Stream<List<BookingItem>> watchBookings(
    DashboardUser user,
    Set<String> salonIds,
  ) => _bookingsController.stream.map(
    (bookings) => _filterBySalon(
      user: user,
      salonIds: salonIds,
      items: bookings,
      salonId: (item) => item.salonId,
    ),
  );

  @override
  Stream<List<ClientProfile>> watchClients(
    DashboardUser user,
    Set<String> salonIds,
  ) => _clientsController.stream.map(
    (clients) => _filterBySalon(
      user: user,
      salonIds: salonIds,
      items: clients,
      salonId: (item) => item.salonId,
    ),
  );

  @override
  Future<void> createAdmin({
    required String name,
    required String email,
    required String password,
    required String salonName,
  }) async {
    final id = 'admin-${DateTime.now().microsecondsSinceEpoch}';
    _users.add(
      DashboardUser(
        id: id,
        name: name,
        email: email,
        role: DashboardRole.salonAdmin,
        subscriptionActive: true,
        primarySalonName: salonName,
      ),
    );
    _passwords[id] = password;
    _salons.add(
      SalonProfile(
        id: 'salon-${DateTime.now().microsecondsSinceEpoch}',
        ownerUserId: id,
        name: salonName,
        locality: 'New Delhi',
        address: 'Add salon address',
        phone: '+91 00000 00000',
        email: email,
        about: 'New salon onboarded by Super Admin.',
        openingTime: '10:00 AM',
        closingTime: '08:00 PM',
        acceptingBookings: true,
      ),
    );
    _emitAll();
  }

  @override
  Future<void> updatePassword(String userId, String password) async {
    _passwords[userId] = password;
  }

  @override
  Future<void> setSubscription(String userId, bool active) async {
    final user = _userById(userId);
    if (user == null || user.role == DashboardRole.superAdmin) return;
    user.subscriptionActive = active;
    _emitAll();
  }

  @override
  Future<void> deleteUser(String userId) async {
    final user = _userById(userId);
    if (user == null || user.role == DashboardRole.superAdmin) return;
    _users.removeWhere((candidate) => candidate.id == userId);
    _passwords.remove(userId);
    final salonIds = _salons
        .where((salon) => salon.ownerUserId == userId)
        .map((salon) => salon.id)
        .toSet();
    _salons.removeWhere((salon) => salon.ownerUserId == userId);
    _team.removeWhere((member) => salonIds.contains(member.salonId));
    _services.removeWhere((service) => salonIds.contains(service.salonId));
    _bookings.removeWhere((booking) => salonIds.contains(booking.salonId));
    _clients.removeWhere((client) => salonIds.contains(client.salonId));
    _emitAll();
  }

  @override
  Future<void> addSalon({
    required String ownerUserId,
    required String name,
    required String locality,
    required String address,
    required String phone,
    required String email,
  }) async {
    _salons.add(
      SalonProfile(
        id: 'salon-${DateTime.now().microsecondsSinceEpoch}',
        ownerUserId: ownerUserId,
        name: name,
        locality: locality,
        address: address,
        phone: phone,
        email: email,
        about: 'New branch added to Groome.',
        openingTime: '10:00 AM',
        closingTime: '08:00 PM',
        acceptingBookings: true,
      ),
    );
    _emitAll();
  }

  @override
  Future<void> updateSalon(SalonProfile salon) async {
    final index = _salons.indexWhere((candidate) => candidate.id == salon.id);
    if (index == -1) return;
    _salons[index] = salon;
    _userById(salon.ownerUserId)?.primarySalonName = salon.name;
    _emitAll();
  }

  @override
  Future<void> setSalonBookings(String salonId, bool acceptingBookings) async {
    final salon = _salonById(salonId);
    if (salon == null) return;
    salon.acceptingBookings = acceptingBookings;
    _emitAll();
  }

  @override
  Future<void> addTeamMember({
    required String salonId,
    required String name,
    required String role,
    required String experience,
  }) async {
    _team.add(
      TeamMember(
        id: 'team-${DateTime.now().microsecondsSinceEpoch}',
        salonId: salonId,
        name: name,
        role: role,
        experience: experience,
        workingDays: 'Mon-Sat',
        workingHours: '10:00 AM - 07:00 PM',
        breakTime: '02:00 PM - 02:30 PM',
        services: const [],
        active: true,
        rating: 4.6,
        bookingsThisMonth: 0,
        revenue: 0,
      ),
    );
    _emitAll();
  }

  @override
  Future<void> setTeamMemberActive(String memberId, bool active) async {
    final member = _teamById(memberId);
    if (member == null) return;
    member.active = active;
    _emitAll();
  }

  @override
  Future<void> removeTeamMember(String memberId) async {
    _team.removeWhere((member) => member.id == memberId);
    for (final service in _services) {
      service.teamMemberIds.remove(memberId);
    }
    _emitAll();
  }

  @override
  Future<void> addService({
    required String salonId,
    required String name,
    required String category,
    required int durationMinutes,
    required int price,
    required List<String> teamMemberIds,
  }) async {
    _services.add(
      ServiceItem(
        id: 'service-${DateTime.now().microsecondsSinceEpoch}',
        salonId: salonId,
        name: name,
        category: category,
        durationMinutes: durationMinutes,
        price: price,
        teamMemberIds: teamMemberIds,
      ),
    );
    _emitAll();
  }

  @override
  Future<void> removeService(String serviceId) async {
    _services.removeWhere((service) => service.id == serviceId);
    _emitAll();
  }

  @override
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
    _bookings.insert(
      0,
      BookingItem(
        id: 'GRM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        salonId: salonId,
        customerName: customerName,
        customerPhone: customerPhone,
        serviceId: serviceId,
        teamMemberId: teamMemberId,
        date: date,
        time: time,
        status: 'Confirmed',
        source: source,
        note: '',
      ),
    );
    final existingClient = _clients.where(
      (client) =>
          client.salonId == salonId &&
          client.phone.replaceAll(' ', '') == customerPhone.replaceAll(' ', ''),
    );
    if (existingClient.isEmpty) {
      _clients.add(
        ClientProfile(
          id: 'client-${DateTime.now().microsecondsSinceEpoch}',
          salonId: salonId,
          name: customerName,
          phone: customerPhone,
          totalVisits: 1,
          totalSpend: servicePrice,
          lastVisit: date,
          noShowCount: 0,
          notes: 'Created from manual booking.',
        ),
      );
    }
    _emitAll();
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    final booking = _bookingById(bookingId);
    if (booking == null) return;
    booking.status = 'Cancelled';
    _emitAll();
  }

  List<T> _filterBySalon<T>({
    required DashboardUser user,
    required Set<String> salonIds,
    required List<T> items,
    required String Function(T item) salonId,
  }) {
    if (user.role == DashboardRole.superAdmin) return items;
    return items.where((item) => salonIds.contains(salonId(item))).toList();
  }

  void _emitAll() {
    if (!_usersController.isClosed) {
      _usersController.add(List.unmodifiable(_users));
      _salonsController.add(List.unmodifiable(_salons));
      _teamController.add(List.unmodifiable(_team));
      _servicesController.add(List.unmodifiable(_services));
      _bookingsController.add(List.unmodifiable(_bookings));
      _clientsController.add(List.unmodifiable(_clients));
    }
  }

  DashboardUser? _userById(String id) {
    for (final user in _users) {
      if (user.id == id) return user;
    }
    return null;
  }

  SalonProfile? _salonById(String id) {
    for (final salon in _salons) {
      if (salon.id == id) return salon;
    }
    return null;
  }

  TeamMember? _teamById(String id) {
    for (final member in _team) {
      if (member.id == id) return member;
    }
    return null;
  }

  BookingItem? _bookingById(String id) {
    for (final booking in _bookings) {
      if (booking.id == id) return booking;
    }
    return null;
  }

  void _seed() {
    _users.addAll([
      DashboardUser(
        id: 'super-admin',
        name: 'Super Admin',
        email: 'super@groome.in',
        role: DashboardRole.superAdmin,
        subscriptionActive: true,
        primarySalonName: 'Groome HQ',
      ),
      DashboardUser(
        id: 'looks-admin',
        name: 'Riya Kapoor',
        email: 'partner@groome.in',
        role: DashboardRole.salonAdmin,
        subscriptionActive: true,
        primarySalonName: 'Looks & Co.',
      ),
      DashboardUser(
        id: 'paused-admin',
        name: 'Arman Malik',
        email: 'paused@groome.in',
        role: DashboardRole.salonAdmin,
        subscriptionActive: false,
        primarySalonName: 'Urban Glow',
      ),
    ]);
    _passwords.addAll({
      'super-admin': 'super1234',
      'looks-admin': 'partner123',
      'paused-admin': 'paused123',
    });

    _salons.addAll([
      SalonProfile(
        id: 'looks-main',
        ownerUserId: 'looks-admin',
        name: 'Looks & Co.',
        locality: 'Connaught Place',
        address: 'Block M, Connaught Place, New Delhi',
        phone: '+91 98765 43210',
        email: 'partner@groome.in',
        about: 'Premium grooming, skin care, and hair studio.',
        openingTime: '10:00 AM',
        closingTime: '09:00 PM',
        acceptingBookings: true,
      ),
      SalonProfile(
        id: 'looks-south',
        ownerUserId: 'looks-admin',
        name: 'Looks & Co. South',
        locality: 'Saket',
        address: 'Select Citywalk District, Saket, New Delhi',
        phone: '+91 98765 43211',
        email: 'saket@groome.in',
        about: 'Express salon for repeat customers and walk-ins.',
        openingTime: '11:00 AM',
        closingTime: '08:30 PM',
        acceptingBookings: true,
      ),
    ]);

    _team.addAll([
      TeamMember(
        id: 'arjun',
        salonId: 'looks-main',
        name: 'Arjun Mehta',
        role: 'Senior Stylist',
        experience: '8 years',
        workingDays: 'Mon-Sat',
        workingHours: '10:00 AM - 07:00 PM',
        breakTime: '02:00 PM - 02:30 PM',
        services: ['Haircut', 'Beard', 'Hair Color'],
        active: true,
        rating: 4.9,
        bookingsThisMonth: 312,
        revenue: 49000,
      ),
      TeamMember(
        id: 'priya',
        salonId: 'looks-main',
        name: 'Priya Sharma',
        role: 'Beauty Expert',
        experience: '6 years',
        workingDays: 'Tue-Sun',
        workingHours: '11:00 AM - 08:00 PM',
        breakTime: '03:00 PM - 03:30 PM',
        services: ['Facial', 'Skin Care', 'Nail Art'],
        active: true,
        rating: 4.8,
        bookingsThisMonth: 278,
        revenue: 52000,
      ),
      TeamMember(
        id: 'rahul',
        salonId: 'looks-main',
        name: 'Rahul Kapoor',
        role: 'Grooming Specialist',
        experience: '5 years',
        workingDays: 'Mon-Fri',
        workingHours: '10:00 AM - 06:00 PM',
        breakTime: '01:30 PM - 02:00 PM',
        services: ['Beard', 'Keratin', 'Haircut'],
        active: true,
        rating: 4.7,
        bookingsThisMonth: 201,
        revenue: 43000,
      ),
      TeamMember(
        id: 'sneha',
        salonId: 'looks-main',
        name: 'Sneha Gupta',
        role: 'Nail Artist',
        experience: '4 years',
        workingDays: 'Wed-Sun',
        workingHours: '12:00 PM - 09:00 PM',
        breakTime: '04:00 PM - 04:30 PM',
        services: ['Nail Art', 'Gel Polish'],
        active: false,
        rating: 4.6,
        bookingsThisMonth: 133,
        revenue: 28000,
      ),
    ]);

    _services.addAll([
      ServiceItem(
        id: 'haircut',
        salonId: 'looks-main',
        name: "Men's Haircut",
        category: 'Hair',
        durationMinutes: 30,
        price: 399,
        teamMemberIds: ['arjun', 'rahul'],
      ),
      ServiceItem(
        id: 'facial',
        salonId: 'looks-main',
        name: 'Classic Facial',
        category: 'Skin Care',
        durationMinutes: 60,
        price: 799,
        teamMemberIds: ['priya'],
      ),
      ServiceItem(
        id: 'beard',
        salonId: 'looks-main',
        name: 'Beard Trim',
        category: 'Grooming',
        durationMinutes: 20,
        price: 249,
        teamMemberIds: ['arjun', 'rahul'],
      ),
      ServiceItem(
        id: 'nails',
        salonId: 'looks-main',
        name: 'Nail Art',
        category: 'Nails',
        durationMinutes: 45,
        price: 499,
        teamMemberIds: ['priya', 'sneha'],
      ),
      ServiceItem(
        id: 'keratin',
        salonId: 'looks-main',
        name: 'Keratin Treatment',
        category: 'Hair',
        durationMinutes: 180,
        price: 3999,
        teamMemberIds: ['rahul'],
      ),
    ]);

    _bookings.addAll([
      BookingItem(
        id: 'GRM-001',
        salonId: 'looks-main',
        customerName: 'Arjun Mehta',
        customerPhone: '+91 98111 11111',
        serviceId: 'haircut',
        teamMemberId: 'arjun',
        date: _today,
        time: '10:00 AM',
        status: 'Confirmed',
        source: 'App',
        note: 'Prefers low fade.',
      ),
      BookingItem(
        id: 'GRM-002',
        salonId: 'looks-main',
        customerName: 'Priya Sharma',
        customerPhone: '+91 98222 22222',
        serviceId: 'facial',
        teamMemberId: 'priya',
        date: _today,
        time: '11:30 AM',
        status: 'Confirmed',
        source: 'Manual',
        note: 'Sensitive skin.',
      ),
      BookingItem(
        id: 'GRM-003',
        salonId: 'looks-main',
        customerName: 'Rahul Kapoor',
        customerPhone: '+91 98333 33333',
        serviceId: 'beard',
        teamMemberId: 'rahul',
        date: _today,
        time: '02:00 PM',
        status: 'Confirmed',
        source: 'Walk-in',
        note: '',
      ),
      BookingItem(
        id: 'GRM-004',
        salonId: 'looks-main',
        customerName: 'Sneha Gupta',
        customerPhone: '+91 98444 44444',
        serviceId: 'nails',
        teamMemberId: 'priya',
        date: _today,
        time: '03:30 PM',
        status: 'Confirmed',
        source: 'App',
        note: 'Chrome finish.',
      ),
      BookingItem(
        id: 'GRM-005',
        salonId: 'looks-main',
        customerName: 'Karan Arora',
        customerPhone: '+91 98555 55555',
        serviceId: 'keratin',
        teamMemberId: 'rahul',
        date: _tomorrow,
        time: '10:00 AM',
        status: 'Cancelled',
        source: 'Phone',
        note: 'Reschedule next week.',
      ),
    ]);

    _clients.addAll([
      ClientProfile(
        id: 'client-arjun',
        salonId: 'looks-main',
        name: 'Arjun Mehta',
        phone: '+91 98111 11111',
        totalVisits: 9,
        totalSpend: 6200,
        lastVisit: _today,
        noShowCount: 0,
        notes: 'Likes Arjun for haircut.',
      ),
      ClientProfile(
        id: 'client-priya',
        salonId: 'looks-main',
        name: 'Priya Sharma',
        phone: '+91 98222 22222',
        totalVisits: 14,
        totalSpend: 15100,
        lastVisit: _today,
        noShowCount: 1,
        notes: 'Send skincare reminders.',
      ),
      ClientProfile(
        id: 'client-karan',
        salonId: 'looks-main',
        name: 'Karan Arora',
        phone: '+91 98555 55555',
        totalVisits: 4,
        totalSpend: 9800,
        lastVisit: '2026-05-30',
        noShowCount: 2,
        notes: 'Warn before booking peak slots.',
      ),
    ]);
  }
}
