import 'package:landing_groom_page/features/dashboard/domain/entities/dashboard_entities.dart';

abstract interface class DashboardRepository {
  String? get currentAuthUid;

  Future<DashboardLoginResult> signIn(String email, String password);

  Future<DashboardUser?> currentUser();

  Future<void> signOut();

  Stream<List<DashboardUser>> watchUsers(DashboardUser user);

  Stream<List<SalonProfile>> watchSalons(DashboardUser user);

  Stream<List<TeamMember>> watchTeam(DashboardUser user, Set<String> salonIds);

  Stream<List<ServiceItem>> watchServices(
    DashboardUser user,
    Set<String> salonIds,
  );

  Stream<List<BookingItem>> watchBookings(
    DashboardUser user,
    Set<String> salonIds,
  );

  Stream<List<ClientProfile>> watchClients(
    DashboardUser user,
    Set<String> salonIds,
  );

  Future<void> createAdmin({
    required String name,
    required String email,
    required String password,
    required String salonName,
  });

  Future<void> updatePassword(String userId, String password);

  Future<void> setSubscription(String userId, bool active);

  Future<void> deleteUser(String userId);

  Future<void> addSalon({
    required String ownerUserId,
    required String name,
    required String locality,
    required String address,
    required String phone,
    required String email,
  });

  Future<void> updateSalon(SalonProfile salon);

  Future<void> setSalonBookings(String salonId, bool acceptingBookings);

  Future<void> addTeamMember({
    required String salonId,
    required String name,
    required String role,
    required String experience,
  });

  Future<void> setTeamMemberActive(String memberId, bool active);

  Future<void> removeTeamMember(String memberId);

  Future<void> addService({
    required String salonId,
    required String name,
    required String category,
    required int durationMinutes,
    required int price,
    required List<String> teamMemberIds,
  });

  Future<void> removeService(String serviceId);

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
  });

  Future<void> cancelBooking(String bookingId);
}
