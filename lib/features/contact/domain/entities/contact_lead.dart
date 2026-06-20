import 'package:equatable/equatable.dart';

class ContactLead extends Equatable {
  const ContactLead({
    required this.name,
    required this.email,
    required this.phone,
    required this.businessName,
    required this.message,
  });

  final String name;
  final String email;
  final String phone;
  final String businessName;
  final String message;

  @override
  List<Object> get props => [name, email, phone, businessName, message];
}
