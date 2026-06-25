import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landing_groom_page/features/contact/domain/entities/contact_lead.dart';
import 'package:landing_groom_page/features/contact/domain/repositories/contact_repository.dart';
import 'package:landing_groom_page/features/contact/domain/usecases/submit_contact.dart';
import 'package:landing_groom_page/features/contact/presentation/pages/contact_page.dart';
import 'package:landing_groom_page/features/contact/presentation/cubit/contact_cubit.dart';

void main() {
  const lead = ContactLead(
    name: 'Asha Shah',
    email: 'asha@example.com',
    phone: '+91 98765 43210',
    businessName: 'Asha Studio',
    message: 'I would like to learn more about Groome.',
  );

  test('emits loading then success when submission completes', () async {
    final repository = _FakeContactRepository();
    final cubit = ContactCubit(SubmitContact(repository));
    final states = <ContactState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.submit(lead);
    await Future<void>.delayed(Duration.zero);

    expect(states, [const ContactLoading(), const ContactSuccess()]);
    expect(repository.submittedLead, lead);

    await subscription.cancel();
    await cubit.close();
  });

  test('emits loading then failure when submission throws', () async {
    final cubit = ContactCubit(SubmitContact(_FailingContactRepository()));
    final states = <ContactState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.submit(lead);
    await Future<void>.delayed(Duration.zero);

    expect(states.first, const ContactLoading());
    expect(states.last, isA<ContactFailure>());

    await subscription.cancel();
    await cubit.close();
  });

  testWidgets('contact form submits entered lead through the repository', (
    tester,
  ) async {
    final repository = _FakeContactRepository();
    final cubit = ContactCubit(SubmitContact(repository));

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: ContactFormCard())),
        ),
      ),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), lead.name);
    await tester.enterText(fields.at(1), lead.email);
    await tester.enterText(fields.at(2), lead.phone);
    await tester.enterText(fields.at(3), lead.businessName);
    await tester.enterText(fields.at(4), lead.message);

    await tester.ensureVisible(find.text('Contact Us'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contact Us'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(repository.submittedLead, lead);
    expect(
      find.text('Thank you! Our team will contact you soon.'),
      findsOneWidget,
    );

    await cubit.close();
  });
}

class _FakeContactRepository implements ContactRepository {
  ContactLead? submittedLead;

  @override
  Future<void> submitContact(ContactLead lead) async {
    submittedLead = lead;
  }
}

class _FailingContactRepository implements ContactRepository {
  @override
  Future<void> submitContact(ContactLead lead) =>
      Future<void>.error(StateError('network unavailable'));
}
