import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:landing_groom_page/app.dart';
import 'package:landing_groom_page/core/services/firebase_bootstrap.dart';
import 'package:landing_groom_page/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: FirebaseBootstrap.options);

  await configureDependencies();
  runApp(const GroomeApp());
}
