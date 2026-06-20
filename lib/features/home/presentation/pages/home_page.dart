import 'package:flutter/widgets.dart';
import 'package:landing_groom_page/core/widgets/site_scaffold.dart';
import 'package:landing_groom_page/features/home/presentation/widgets/hero_section.dart';
import 'package:landing_groom_page/features/home/presentation/widgets/home_sections.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const SiteScaffold(
    child: SingleChildScrollView(
      child: Column(
        children: [
          HeroSection(),
          WhyGroomeSection(),
          HowItWorksSection(),
          StatisticsSection(),
          TestimonialsSection(),
          HomeCtaSection(),
          SiteFooter(),
        ],
      ),
    ),
  );
}
