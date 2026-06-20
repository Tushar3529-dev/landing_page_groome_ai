import 'package:landing_groom_page/features/contact/domain/entities/contact_lead.dart';
import 'package:landing_groom_page/features/contact/domain/repositories/contact_repository.dart';

class SubmitContact {
  const SubmitContact(this._repository);

  final ContactRepository _repository;

  Future<void> call(ContactLead lead) => _repository.submitContact(lead);
}
