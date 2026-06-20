import 'package:landing_groom_page/features/contact/data/datasources/firebase_contact_datasource.dart';
import 'package:landing_groom_page/features/contact/domain/entities/contact_lead.dart';
import 'package:landing_groom_page/features/contact/domain/repositories/contact_repository.dart';

class ContactRepositoryImpl implements ContactRepository {
  const ContactRepositoryImpl(this._datasource);

  final ContactDatasource _datasource;

  @override
  Future<void> submitContact(ContactLead lead) =>
      _datasource.submitContact(lead);
}
