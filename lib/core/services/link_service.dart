import 'package:url_launcher/url_launcher.dart';

abstract final class LinkService {
  static Future<void> open(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, webOnlyWindowName: '_blank')) {
      throw StateError('Could not open $url');
    }
  }
}
