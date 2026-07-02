import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:landing_groom_page/core/constants/app_constants.dart';
import 'package:landing_groom_page/core/content/site_content.dart';
import 'package:landing_groom_page/core/themes/app_theme.dart';
import 'package:landing_groom_page/features/about/presentation/pages/about_page.dart';
import 'package:landing_groom_page/features/contact/presentation/cubit/contact_cubit.dart';
import 'package:landing_groom_page/features/contact/presentation/pages/contact_page.dart';
// import 'package:landing_groom_page/features/features/presentation/pages/features_page.dart';
import 'package:landing_groom_page/features/home/presentation/pages/home_page.dart';
import 'package:landing_groom_page/features/legal/presentation/pages/legal_page.dart';
import 'package:landing_groom_page/injection_container.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
    // GoRoute(path: AppRoutes.features, builder: (_, _) => const FeaturesPage()),
    GoRoute(path: AppRoutes.about, builder: (_, _) => const AboutPage()),
    GoRoute(
      path: AppRoutes.privacyPolicy,
      builder: (_, _) =>
          const LegalPage(document: LegalDocuments.privacyPolicy),
    ),
    GoRoute(
      path: AppRoutes.termsConditions,
      builder: (_, _) =>
          const LegalPage(document: LegalDocuments.termsConditions),
    ),
    GoRoute(
      path: AppRoutes.contact,
      builder: (_, _) => BlocProvider(
        create: (_) => sl<ContactCubit>(),
        child: const ContactPage(),
      ),
    ),
  ],
  errorBuilder: (_, _) => const HomePage(),
);

class GroomeApp extends StatelessWidget {
  const GroomeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Groome - Bring Your Salon Online',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    routerConfig: _router,
  );
}
