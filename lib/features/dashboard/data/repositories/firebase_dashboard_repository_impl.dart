import 'package:landing_groom_page/features/dashboard/data/datasources/firebase_dashboard_datasource.dart';
import 'package:landing_groom_page/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:landing_groom_page/features/dashboard/domain/repositories/dashboard_repository.dart';

class FirebaseDashboardRepositoryImpl implements DashboardRepository {
  FirebaseDashboardRepositoryImpl(this._datasource);

  final FirebaseDashboardDatasource _datasource;

  @override
  String? get currentAuthUid => _datasource.currentAuthUid;

  @override
  Future<DashboardLoginResult> signIn(String email, String password) =>
      _datasource.signIn(email, password);

  @override
  Future<DashboardUser?> currentUser() {
    final uid = currentAuthUid;
    if (uid == null) return Future.value();
    return _datasource.dashboardUser(uid);
  }

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  Stream<List<DashboardUser>> watchUsers(DashboardUser user) =>
      _datasource.watchUsers(user);

  @override
  Stream<List<SalonProfile>> watchSalons(DashboardUser user) =>
      _datasource.watchSalons(user);

  @override
  Stream<List<TeamMember>> watchTeam(
    DashboardUser user,
    Set<String> salonIds,
  ) => _datasource.watchTeam(user, salonIds);

  @override
  Stream<List<ServiceItem>> watchServices(
    DashboardUser user,
    Set<String> salonIds,
  ) => _datasource.watchServices(user, salonIds);

  @override
  Stream<List<BookingItem>> watchBookings(
    DashboardUser user,
    Set<String> salonIds,
  ) => _datasource.watchBookings(user, salonIds);

  @override
  Stream<List<ClientProfile>> watchClients(
    DashboardUser user,
    Set<String> salonIds,
  ) => _datasource.watchClients(user, salonIds);

  @override
  Future<void> createAdmin({
    required String name,
    required String email,
    required String password,
    required String salonName,
  }) => _datasource.createAdmin(
    name: name,
    email: email,
    password: password,
    salonName: salonName,
  );

  @override
  Future<void> updatePassword(String userId, String password) =>
      _datasource.updatePassword(userId, password);

  @override
  Future<void> setSubscription(String userId, bool active) =>
      _datasource.setSubscription(userId, active);

  @override
  Future<void> deleteUser(String userId) => _datasource.deleteUser(userId);

  @override
  Future<void> addSalon({
    required String ownerUserId,
    required String name,
    required String locality,
    required String address,
    required String phone,
    required String email,
  }) => _datasource.addSalon(
    ownerUserId: ownerUserId,
    name: name,
    locality: locality,
    address: address,
    phone: phone,
    email: email,
  );

  @override
  Future<void> updateSalon(SalonProfile salon) =>
      _datasource.updateSalon(salon);

  @override
  Future<void> setSalonBookings(String salonId, bool acceptingBookings) =>
      _datasource.setSalonBookings(salonId, acceptingBookings);

  @override
  Future<void> addTeamMember({
    required String salonId,
    required String name,
    required String role,
    required String experience,
  }) => _datasource.addTeamMember(
    salonId: salonId,
    name: name,
    role: role,
    experience: experience,
  );

  @override
  Future<void> setTeamMemberActive(String memberId, bool active) =>
      _datasource.setTeamMemberActive(memberId, active);

  @override
  Future<void> removeTeamMember(String memberId) =>
      _datasource.removeTeamMember(memberId);

  @override
  Future<void> addService({
    required String salonId,
    required String name,
    required String category,
    required int durationMinutes,
    required int price,
    required List<String> teamMemberIds,
  }) => _datasource.addService(
    salonId: salonId,
    name: name,
    category: category,
    durationMinutes: durationMinutes,
    price: price,
    teamMemberIds: teamMemberIds,
  );

  @override
  Future<void> removeService(String serviceId) =>
      _datasource.removeService(serviceId);

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
  }) => _datasource.addBooking(
    salonId: salonId,
    customerName: customerName,
    customerPhone: customerPhone,
    serviceId: serviceId,
    teamMemberId: teamMemberId,
    date: date,
    time: time,
    source: source,
    servicePrice: servicePrice,
  );

  @override
  Future<void> cancelBooking(String bookingId) =>
      _datasource.cancelBooking(bookingId);
}
