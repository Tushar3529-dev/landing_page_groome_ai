enum DashboardRole {
  superAdmin('superAdmin'),
  salonAdmin('salonAdmin');

  const DashboardRole(this.value);

  final String value;

  static DashboardRole fromValue(String? value) =>
      value == DashboardRole.superAdmin.value
      ? DashboardRole.superAdmin
      : DashboardRole.salonAdmin;
}

class DashboardLoginResult {
  const DashboardLoginResult({required this.success, this.user, this.message});

  final bool success;
  final DashboardUser? user;
  final String? message;
}

class DashboardUser {
  DashboardUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.subscriptionActive,
    required this.primarySalonName,
  });

  final String id;
  String name;
  String email;
  final DashboardRole role;
  bool subscriptionActive;
  String primarySalonName;
}

class SalonProfile {
  SalonProfile({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.locality,
    required this.address,
    required this.phone,
    required this.email,
    required this.about,
    required this.openingTime,
    required this.closingTime,
    required this.acceptingBookings,
  });

  final String id;
  final String ownerUserId;
  String name;
  String locality;
  String address;
  String phone;
  String email;
  String about;
  String openingTime;
  String closingTime;
  bool acceptingBookings;
}

class TeamMember {
  TeamMember({
    required this.id,
    required this.salonId,
    required this.name,
    required this.role,
    required this.experience,
    required this.workingDays,
    required this.workingHours,
    required this.breakTime,
    required this.services,
    required this.active,
    required this.rating,
    required this.bookingsThisMonth,
    required this.revenue,
  });

  final String id;
  final String salonId;
  String name;
  String role;
  String experience;
  String workingDays;
  String workingHours;
  String breakTime;
  List<String> services;
  bool active;
  double rating;
  int bookingsThisMonth;
  int revenue;
}

class ServiceItem {
  ServiceItem({
    required this.id,
    required this.salonId,
    required this.name,
    required this.category,
    required this.durationMinutes,
    required this.price,
    required this.teamMemberIds,
  });

  final String id;
  final String salonId;
  String name;
  String category;
  int durationMinutes;
  int price;
  List<String> teamMemberIds;
}

class BookingItem {
  BookingItem({
    required this.id,
    required this.salonId,
    required this.customerName,
    required this.customerPhone,
    required this.serviceId,
    required this.teamMemberId,
    required this.date,
    required this.time,
    required this.status,
    required this.source,
    required this.note,
  });

  final String id;
  final String salonId;
  String customerName;
  String customerPhone;
  String serviceId;
  String teamMemberId;
  String date;
  String time;
  String status;
  String source;
  String note;
}

class ClientProfile {
  ClientProfile({
    required this.id,
    required this.salonId,
    required this.name,
    required this.phone,
    required this.totalVisits,
    required this.totalSpend,
    required this.lastVisit,
    required this.noShowCount,
    required this.notes,
  });

  final String id;
  final String salonId;
  String name;
  String phone;
  int totalVisits;
  int totalSpend;
  String lastVisit;
  int noShowCount;
  String notes;
}
