import 'package:flutter/material.dart';
import 'package:landing_groom_page/core/constants/app_constants.dart';
import 'package:landing_groom_page/core/utils/responsive.dart';
import 'package:landing_groom_page/core/widgets/hover_surface.dart';
import 'package:landing_groom_page/core/widgets/reveal.dart';
import 'package:landing_groom_page/core/widgets/section_container.dart';
import 'package:landing_groom_page/core/widgets/site_scaffold.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => const SiteScaffold(
    child: SingleChildScrollView(
      child: Column(children: [_AboutIntro(), _MissionSection(), SiteFooter()]),
    ),
  );
}

class _AboutIntro extends StatelessWidget {
  const _AboutIntro();

  @override
  Widget build(BuildContext context) => SectionContainer(
    color: AppColors.cream,
    padding: EdgeInsets.fromLTRB(
      context.pagePadding,
      context.isMobile ? 58 : 86,
      context.pagePadding,
      context.isMobile ? 76 : 104,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Reveal(child: _IntroHeading()),
        SizedBox(height: context.isMobile ? 42 : 58),
        if (context.isMobile)
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Reveal(delay: Duration(milliseconds: 100), child: _StoryCopy()),
              SizedBox(height: 36),
              Reveal(delay: Duration(milliseconds: 180), child: _SalonImage()),
              SizedBox(height: 24),
              Reveal(
                delay: Duration(milliseconds: 240),
                child: _FoundersNote(),
              ),
            ],
          )
        else
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 11,
                child: Reveal(
                  delay: Duration(milliseconds: 100),
                  child: _StoryCopy(),
                ),
              ),
              SizedBox(width: 72),
              Expanded(
                flex: 9,
                child: Column(
                  children: [
                    Reveal(
                      delay: Duration(milliseconds: 180),
                      child: _SalonImage(),
                    ),
                    SizedBox(height: 24),
                    Reveal(
                      delay: Duration(milliseconds: 240),
                      child: _FoundersNote(),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    ),
  );
}

class _IntroHeading extends StatelessWidget {
  const _IntroHeading();

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 980),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ABOUT US',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.goldDark,
            fontSize: 11,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'We\'re building the future of India\'s salon industry',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: context.isMobile ? 52 : 72,
          ),
        ),
      ],
    ),
  );
}

class _StoryCopy extends StatelessWidget {
  const _StoryCopy();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Every day, customers struggle to discover trusted salons, compare '
        'services, and book appointments effortlessly. At the same time, many '
        'salon owners still rely on phone calls, WhatsApp messages, and manual '
        'records to manage their business and attract new customers.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 24),
      Text(
        'Groome brings both sides together on one platform. Customers can '
        'discover, compare, and instantly book salons through the Groome app, '
        'while salon owners manage bookings, customers, marketing, and daily '
        'operations from one unified dashboard. We\'re starting in Delhi with '
        'a vision to build the platform every salon in India grows with.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    ],
  );
}

class _SalonImage extends StatelessWidget {
  const _SalonImage();

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: AspectRatio(
      aspectRatio: context.isMobile ? 1.18 : 1.4,
      child: Image.asset(
        AppAssets.salonOwner,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        semanticLabel: 'Salon owner at work',
      ),
    ),
  );
}

class _FoundersNote extends StatelessWidget {
  const _FoundersNote();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(context.isMobile ? 24 : 28),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.line),
      boxShadow: [
        BoxShadow(
          color: AppColors.ink.withValues(alpha: .035),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'FOUNDERS’ NOTE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.goldDark,
                fontSize: 10,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '“Great salons deserve great technology.”',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: context.isMobile ? 30 : 34,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Groome was created with a simple belief: great salons deserve '
          'great technology. We\'re building a platform that helps salon '
          'owners spend less time managing bookings and more time growing '
          'their business.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );
}

class _MissionSection extends StatelessWidget {
  const _MissionSection();

  static const _items = [
    (
      Icons.location_on_outlined,
      'Discover',
      'Help customers find great salons nearby.',
    ),
    (
      Icons.calendar_month_outlined,
      'Book',
      'Instant online appointments without phone calls.',
    ),
    (
      Icons.trending_up_rounded,
      'Grow',
      'Give salons tools to attract and retain customers.',
    ),
    (
      Icons.handshake_outlined,
      'Connect',
      'Bring customers and salon owners together in one ecosystem.',
    ),
  ];

  @override
  Widget build(BuildContext context) => SectionContainer(
    color: AppColors.softCream,
    child: Column(
      children: [
        const Reveal(child: _MissionHeading()),
        SizedBox(height: context.isMobile ? 42 : 58),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = context.isMobile ? 1 : (context.isTablet ? 2 : 4);
            final gap = context.isMobile ? 16.0 : 20.0;
            final cardWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < _items.length; i++)
                  SizedBox(
                    width: cardWidth,
                    child: Reveal(
                      delay: Duration(milliseconds: 90 * i),
                      child: _MissionCard(item: _items[i]),
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

class _MissionHeading extends StatelessWidget {
  const _MissionHeading();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        'OUR MISSION',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.goldDark,
          fontSize: 11,
          letterSpacing: 1.6,
        ),
      ),
      const SizedBox(height: 14),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Text(
          'To make every salon in India discoverable, bookable, and '
          'manageable from one platform.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontSize: context.isMobile ? 41 : 56,
          ),
        ),
      ),
    ],
  );
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.item});

  final (IconData, String, String) item;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: context.isMobile ? null : 256,
    child: HoverSurface(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(item.$1, color: AppColors.goldDark, size: 25),
          ),
          const SizedBox(height: 20),
          Text(item.$2, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            item.$3,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    ),
  );
}
