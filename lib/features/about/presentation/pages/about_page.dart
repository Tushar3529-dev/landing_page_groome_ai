import 'package:flutter/material.dart';
import 'package:landing_groom_page/core/constants/app_constants.dart';
import 'package:landing_groom_page/core/widgets/section_container.dart';
import 'package:landing_groom_page/core/widgets/site_scaffold.dart';
import 'package:landing_groom_page/features/home/presentation/widgets/home_sections.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => const SiteScaffold(
    child: SingleChildScrollView(
      child: Column(
        children: [
          SectionContainer(
            color: AppColors.cream,
            child: SectionHeading(
              eyebrow: 'About Groome',
              title: 'Technology with salon hospitality at heart',
              description:
                  'Groome helps independent salon teams spend less time managing admin and more time creating exceptional customer experiences.',
            ),
          ),
          SiteFooter(),
        ],
      ),
    ),
  );
}
