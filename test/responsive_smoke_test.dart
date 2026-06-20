import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landing_groom_page/app.dart';
import 'package:landing_groom_page/injection_container.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await configureDependencies();
  });

  testWidgets('renders home page on desktop without layout exceptions', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1440, 1200));

    await tester.pumpWidget(const GroomeApp());
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.textContaining('Bring Your'), findsOneWidget);
    expect(find.text('Online Booking'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders home page on mobile without layout exceptions', (
    tester,
  ) async {
    await _setSurface(tester, const Size(390, 1200));

    await tester.pumpWidget(const GroomeApp());
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.byTooltip('Open menu'), findsOneWidget);
    expect(find.textContaining('Bring Your'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
