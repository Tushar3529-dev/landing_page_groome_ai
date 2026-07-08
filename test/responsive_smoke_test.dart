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

    expect(
      find.text('Get discovered. Get booked. Grow your salon.'),
      findsOneWidget,
    );
    expect(find.text('Go to Dashboard'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders home page on mobile without layout exceptions', (
    tester,
  ) async {
    await _setSurface(tester, const Size(390, 1200));

    await tester.pumpWidget(const GroomeApp());
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.byTooltip('Open menu'), findsOneWidget);
    expect(
      find.text('Get discovered. Get booked. Grow your salon.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens dashboard login and blocks stopped subscriptions', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1440, 1200));

    await tester.pumpWidget(const GroomeApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Go to Dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create User'), findsNothing);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'paused@groome.in');
    await tester.enterText(fields.at(1), 'paused123');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Your subscription is stopped. Please contact with Super Admin.',
      ),
      findsOneWidget,
    );

    await tester.enterText(fields.at(0), 'super@groome.in');
    await tester.enterText(fields.at(1), 'super1234');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Admins'), findsWidgets);
    await tester.tap(find.text('Admins').first);
    await tester.pumpAndSettle();
    expect(find.text('Create User'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('groome').first);
    await tester.pumpAndSettle();
  });

  testWidgets('renders about page responsively without layout exceptions', (
    tester,
  ) async {
    for (final size in const [Size(1440, 1200), Size(390, 1200)]) {
      await _setSurface(tester, size);

      await tester.pumpWidget(const GroomeApp());
      await tester.pumpAndSettle();
      await tester.tap(
        size.width < 680
            ? find.byTooltip('Open menu')
            : find.text('About').first,
      );
      await tester.pumpAndSettle();

      if (size.width < 680) {
        await tester.tap(find.text('About'));
        await tester.pumpAndSettle();
      }

      expect(
        find.text('We\'re building the future of India\'s salon industry'),
        findsOneWidget,
      );
      expect(find.text('FOUNDERS’ NOTE'), findsOneWidget);
      expect(find.text('OUR MISSION'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Connect'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('navigates to policy pages from the footer', (tester) async {
    await _setSurface(tester, const Size(1440, 1800));

    await tester.pumpWidget(const GroomeApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Privacy Policy'));
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();

    expect(find.text('Privacy Policy'), findsWidgets);
    expect(find.textContaining('Groome is committed'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Terms & Conditions'));
    await tester.tap(find.text('Terms & Conditions'));
    await tester.pumpAndSettle();

    expect(find.text('Terms & Conditions'), findsWidgets);
    expect(find.textContaining('These Terms explain'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
