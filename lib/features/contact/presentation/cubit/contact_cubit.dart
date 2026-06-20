import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landing_groom_page/features/contact/domain/entities/contact_lead.dart';
import 'package:landing_groom_page/features/contact/domain/usecases/submit_contact.dart';

part 'contact_state.dart';

class ContactCubit extends Cubit<ContactState> {
  ContactCubit(this._submitContact) : super(const ContactInitial());

  final SubmitContact _submitContact;

  Future<void> submit(ContactLead lead) async {
    if (state is ContactLoading) return;
    emit(const ContactLoading());

    try {
      await _submitContact(lead);
      emit(const ContactSuccess());
    } catch (_) {
      emit(
        const ContactFailure(
          'We could not send your message right now. Please try again shortly.',
        ),
      );
    }
  }

  void reset() => emit(const ContactInitial());
}
