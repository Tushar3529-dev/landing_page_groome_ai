import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:landing_groom_page/core/constants/app_constants.dart';
import 'package:landing_groom_page/core/utils/responsive.dart';
import 'package:landing_groom_page/core/widgets/app_button.dart';
import 'package:landing_groom_page/core/widgets/hover_surface.dart';
import 'package:landing_groom_page/core/widgets/reveal.dart';
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
          _AboutHero(),
          _AboutStorySection(),
          _AboutValuesSection(),
          _AboutAudienceSection(),
          _AboutCtaSection(),
          SiteFooter(),
        ],
      ),
    ),
  );
}

class _AboutHero extends StatelessWidget {
  const _AboutHero();

  @override
  Widget build(BuildContext context) => SectionContainer(
    color: AppColors.cream,
    padding: EdgeInsets.fromLTRB(
      context.pagePadding,
      context.isMobile ? 58 : 86,
      context.pagePadding,
      context.isMobile ? 70 : 96,
    ),
    child: context.isMobile
        ? const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Reveal(child: _AboutHeroCopy()),
              SizedBox(height: 42),
              Reveal(
                delay: Duration(milliseconds: 140),
                child: _AboutHeroImage(),
              ),
            ],
          )
        : const Row(
            children: [
              Expanded(flex: 10, child: Reveal(child: _AboutHeroCopy())),
              SizedBox(width: 68),
              Expanded(
                flex: 9,
                child: Reveal(
                  delay: Duration(milliseconds: 140),
                  child: _AboutHeroImage(),
                ),
              ),
            ],
          ),
  );
}

class _AboutHeroCopy extends StatelessWidget {
  const _AboutHeroCopy();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'ABOUT US',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.goldDark,
          fontSize: 11,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 18),
      Text(
        'Built for salons that want calmer, smarter growth',
        style: Theme.of(context).textTheme.displayMedium,
      ),
      const SizedBox(height: 24),
      Text(
        'Groome is a digital platform for salon businesses that want online bookings, customer records, reminders, and business visibility without adding more admin to the day.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 32),
      AppButton(
        label: 'Get in touch',
        icon: Icons.arrow_outward_rounded,
        onPressed: () => context.go(AppRoutes.contact),
      ),
    ],
  );
}

class _AboutHeroImage extends StatelessWidget {
  const _AboutHeroImage();

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(30),
    child: AspectRatio(
      aspectRatio: context.isMobile ? 1 : .92,
      child: Image.asset(
        AppAssets.salonOwner,
        fit: BoxFit.cover,
        semanticLabel: 'Salon owner using Groome',
      ),
    ),
  );
}

class _AboutStorySection extends StatelessWidget {
  const _AboutStorySection();

  @override
  Widget build(BuildContext context) => SectionContainer(
    child: context.isMobile
        ? const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading(
                eyebrow: 'Our story',
                title: 'Practical software for real salon days',
                description:
                    'We believe salon technology should feel clear, reliable, and human. Groome is designed around the everyday work of owners, front desks, stylists, and customers.',
                centered: false,
              ),
              SizedBox(height: 34),
              _StoryPoints(),
            ],
          )
        : const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SectionHeading(
                  eyebrow: 'Our story',
                  title: 'Practical software for real salon days',
                  description:
                      'We believe salon technology should feel clear, reliable, and human. Groome is designed around the everyday work of owners, front desks, stylists, and customers.',
                  centered: false,
                ),
              ),
              SizedBox(width: 76),
              Expanded(child: _StoryPoints()),
            ],
          ),
  );
}

class _StoryPoints extends StatelessWidget {
  const _StoryPoints();

  static const _items = [
    (
      Icons.event_available_outlined,
      'Bookings without back-and-forth',
      'Customers can discover services and book quickly while salon teams keep control of the schedule.',
    ),
    (
      Icons.groups_2_outlined,
      'Customer memory that stays organised',
      'Profiles, preferences, and visit history help teams deliver more personal service.',
    ),
    (
      Icons.insights_rounded,
      'Simple visibility for owners',
      'Clear activity and revenue signals help salon owners make better daily decisions.',
    ),
  ];

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < _items.length; i++)
        Padding(
          padding: EdgeInsets.only(bottom: i == _items.length - 1 ? 0 : 18),
          child: Reveal(
            delay: Duration(milliseconds: 90 * i),
            child: _StoryPoint(item: _items[i]),
          ),
        ),
    ],
  );
}

class _StoryPoint extends StatelessWidget {
  const _StoryPoint({required this.item});

  final (IconData, String, String) item;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(item.$1, color: AppColors.goldDark),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.$2, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(item.$3, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    ],
  );
}

class _AboutValuesSection extends StatelessWidget {
  const _AboutValuesSection();

  static const _values = [
    (
      Icons.spa_outlined,
      'Hospitality first',
      'Software should support the customer experience, not distract from it.',
    ),
    (
      Icons.verified_user_outlined,
      'Trust by design',
      'Customer and salon data should be handled carefully, clearly, and securely.',
    ),
    (
      Icons.auto_awesome_motion_outlined,
      'Less operational noise',
      'The best tools remove repeated work and make the next action obvious.',
    ),
  ];

  @override
  Widget build(BuildContext context) => SectionContainer(
    color: AppColors.softCream,
    child: Column(
      children: [
        const SectionHeading(
          eyebrow: 'What guides us',
          title: 'Designed around trust, clarity, and momentum',
          description:
              'Groome is built for businesses that care about quality service and steady growth.',
        ),
        const SizedBox(height: 54),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = context.isMobile ? 1 : 3;
            final gap = context.isMobile ? 18.0 : 22.0;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < _values.length; i++)
                  SizedBox(
                    width: width,
                    child: Reveal(
                      delay: Duration(milliseconds: 90 * i),
                      child: HoverSurface(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(_values[i].$1, color: AppColors.goldDark),
                            const SizedBox(height: 24),
                            Text(
                              _values[i].$2,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _values[i].$3,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    ),
  );
}

class _AboutAudienceSection extends StatelessWidget {
  const _AboutAudienceSection();

  @override
  Widget build(BuildContext context) => SectionContainer(
    child: Column(
      children: [
        const SectionHeading(
          eyebrow: 'Who we serve',
          title: 'For independent salons, studios, and growing teams',
          description:
              'Whether a salon is taking its first online bookings or scaling across a team, Groome gives the business a cleaner operating rhythm.',
        ),
        const SizedBox(height: 42),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: const [
            _AudiencePill('Salon owners'),
            _AudiencePill('Front desk teams'),
            _AudiencePill('Stylists and artists'),
            _AudiencePill('Multi-service studios'),
            _AudiencePill('Beauty and grooming businesses'),
          ],
        ),
      ],
    ),
  );
}

class _AudiencePill extends StatelessWidget {
  const _AudiencePill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
    decoration: BoxDecoration(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: AppColors.line),
    ),
    child: Text(label, style: Theme.of(context).textTheme.labelLarge),
  );
}

class _AboutCtaSection extends StatelessWidget {
  const _AboutCtaSection();

  @override
  Widget build(BuildContext context) => SectionContainer(
    color: AppColors.cream,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 26 : 56,
        vertical: context.isMobile ? 42 : 54,
      ),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(28),
      ),
      child: context.isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _copy(context),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Contact us',
                  light: true,
                  outlined: true,
                  onPressed: () => context.go(AppRoutes.contact),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(child: _copy(context)),
                const SizedBox(width: 34),
                AppButton(
                  label: 'Contact us',
                  light: true,
                  outlined: true,
                  icon: Icons.arrow_outward_rounded,
                  onPressed: () => context.go(AppRoutes.contact),
                ),
              ],
            ),
    ),
  );

  Widget _copy(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'GET IN TOUCH',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.gold,
          fontSize: 11,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Want to bring your salon online with Groome?',
        style: Theme.of(
          context,
        ).textTheme.headlineLarge?.copyWith(color: AppColors.white),
      ),
    ],
  );
}
