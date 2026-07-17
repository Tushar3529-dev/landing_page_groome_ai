import 'package:firebase_core/firebase_core.dart';
import 'package:landing_groom_page/firebase_options.dart';

/// Provides Firebase options for the app.
///
/// The generated FlutterFire options are used by default so the deployed site
/// works with the configured Firebase project. Environment dart-defines remain
/// supported as an override for staging or white-label deployments.
abstract final class FirebaseBootstrap {
  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );

  static bool get hasEnvironmentConfig =>
      _apiKey.isNotEmpty &&
      _appId.isNotEmpty &&
      _messagingSenderId.isNotEmpty &&
      _projectId.isNotEmpty;

  static FirebaseOptions get options {
    final configuredOptions = hasEnvironmentConfig
        ? _environmentOptions
        : DefaultFirebaseOptions.web;
    final authDomain = _customAuthDomainForCurrentHost;
    if (authDomain == null ||
        configuredOptions.authDomain == authDomain ||
        (hasEnvironmentConfig && _authDomain.isNotEmpty)) {
      return configuredOptions;
    }
    return configuredOptions.copyWith(authDomain: authDomain);
  }

  static String? get _customAuthDomainForCurrentHost {
    final host = Uri.base.host.toLowerCase();
    return host == 'groome.net' ? host : null;
  }

  static FirebaseOptions get _environmentOptions => FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    authDomain: _authDomain.isEmpty ? null : _authDomain,
    storageBucket: _storageBucket.isEmpty ? null : _storageBucket,
  );
}
