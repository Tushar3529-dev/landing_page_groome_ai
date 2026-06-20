import 'package:landing_groom_page/features/contact/domain/entities/contact_lead.dart';

abstract interface class ContactRepository {
  Future<void> submitContact(ContactLead lead);
}
