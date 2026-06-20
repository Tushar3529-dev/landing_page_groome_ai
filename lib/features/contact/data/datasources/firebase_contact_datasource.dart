import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:landing_groom_page/features/contact/domain/entities/contact_lead.dart';

abstract interface class ContactDatasource {
  Future<void> submitContact(ContactLead lead);
}

class FirebaseContactDatasource implements ContactDatasource {
  const FirebaseContactDatasource();

  @override
  Future<void> submitContact(ContactLead lead) async {
    if (Firebase.apps.isEmpty) {
      throw const FirebaseConfigurationException();
    }

    await FirebaseFirestore.instance.collection('contact_leads').add({
      'name': lead.name.trim(),
      'email': lead.email.trim().toLowerCase(),
      'phone': lead.phone.trim(),
      'businessName': lead.businessName.trim(),
      'message': lead.message.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

class FirebaseConfigurationException implements Exception {
  const FirebaseConfigurationException();

  @override
  String toString() => 'Contact service is not configured yet.';
}
