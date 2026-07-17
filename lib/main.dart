import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:landing_groom_page/app.dart';
import 'package:landing_groom_page/core/services/firebase_bootstrap.dart';
import 'package:landing_groom_page/core/services/web_firebase_plugin_registrant.dart'
    if (dart.library.html)
        'package:landing_groom_page/core/services/web_firebase_plugin_registrant_web.dart';
import 'package:landing_groom_page/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  registerWebFirebasePlugins();

  final firebaseOptions = FirebaseBootstrap.options;
  // ignore: avoid_print
  print('Groome Firebase authDomain=${firebaseOptions.authDomain}');
  await Firebase.initializeApp(options: firebaseOptions);

  await configureDependencies();
  runApp(const GroomeApp());
}
