import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:landing_groom_page/core/constants/app_constants.dart';
import 'package:landing_groom_page/core/utils/responsive.dart';
import 'package:landing_groom_page/core/widgets/app_button.dart';
import 'package:landing_groom_page/core/widgets/reveal.dart';
import 'package:landing_groom_page/core/widgets/section_container.dart';
import 'package:landing_groom_page/core/widgets/site_scaffold.dart';
import 'package:landing_groom_page/features/home/presentation/widgets/home_sections.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  static const _features = [
    (
      'Online Appointment Booking',
      'Let clients book in seconds',
      'A polished booking journey that works around the clock, keeps availability accurate, and gives your front desk room to breathe.',
      [
        'Live availability',
        'Service and staff selection',
        'Mobile-first booking',
      ],
      Icons.event_available_outlined,
      AppAssets.salonInterior,
    ),
    (
      'Customer Management',
      'Know every client better',
      'Keep visit history, preferences, notes, and upcoming appointments in one clear customer profile your team can trust.',
      ['Complete visit history', 'Customer notes', 'Smart client search'],
      Icons.groups_2_outlined,
      AppAssets.salonConsultation,
    ),
    (
      'Revenue Tracking',
      'See what drives your growth',
      'Understand daily sales, popular services, and team performance without wrestling with another spreadsheet.',
      ['Daily revenue overview', 'Service performance', 'Simple comparisons'],
      Icons.currency_rupee_rounded,
      AppAssets.salonOwner,
    ),
    (
      'WhatsApp Notifications',
      'Keep customers in the loop',
      'Send timely booking confirmations and reminders through the channel your customers already use every day.',
      ['Automatic confirmations', 'Appointment reminders', 'Fewer no-shows'],
      Icons.chat_bubble_outline_rounded,
      AppAssets.salonConsultation,
    ),
    (
      'Partner Dashboard',
      'Run the day from one place',
      'See appointments, customers, staff schedules, and business activity from a focused dashboard built for busy teams.',
      ['At-a-glance schedule', 'Staff visibility', 'Fast daily actions'],
      Icons.space_dashboard_outlined,
      AppAssets.salonInterior,
    ),
    (
      'Business Analytics',
      'Make confident decisions',
      'Spot booking patterns, customer retention, and revenue trends so your next move is based on evidence—not instinct alone.',
      ['Retention insights', 'Booking trends', 'Clear visual reports'],
      Icons.insights_rounded,
      AppAssets.salonOwner,
    ),
  ];

  @override
  Widget build(BuildContext context) => SiteScaffold(
    child: SingleChildScrollView(
      child: Column(
        children: [
          const _FeaturesHeader(),
          for (var i = 0; i < _features.length; i++)
            _FeatureRow(feature: _features[i], reversed: i.isOdd, index: i),
          const _FeatureCta(),
          const SiteFooter(),
        ],
      ),
    ),
  );
}

class _FeaturesHeader extends StatelessWidget {
  const _FeaturesHeader();

  @override
  Widget build(BuildContext context) => SectionContainer(
    color: AppColors.cream,
    padding: EdgeInsets.fromLTRB(
      context.pagePadding,
      context.isMobile ? 70 : 104,
      context.pagePadding,
      context.isMobile ? 76 : 112,
    ),
    child: const Reveal(
      child: SectionHeading(
        eyebrow: 'Platform features',
        title: 'Your business, beautifully organized',
        description:
            'Six connected tools. One calm place to manage bookings, customers, communication, and growth.',
      ),
    ),
  );
}

typedef FeatureRecord = (
  String,
  String,
  String,
  List<String>,
  IconData,
  String,
);

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.feature,
    required this.reversed,
    required this.index,
  });

  final FeatureRecord feature;
  final bool reversed;
  final int index;

  @override
  Widget build(BuildContext context) {
    final image = Reveal(
      child: Hero(
        tag: 'feature-image-$index',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: AspectRatio(
            aspectRatio: 1.2,
            child: Image.asset(
              feature.$6,
              fit: BoxFit.cover,
              semanticLabel: feature.$1,
            ),
          ),
        ),
      ),
    );
    final copy = Reveal(
      delay: const Duration(milliseconds: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(feature.$5, color: AppColors.goldDark),
          ),
          const SizedBox(height: 28),
          Text(
            feature.$1.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.goldDark,
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(feature.$2, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 18),
          Text(feature.$3, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          for (final item in feature.$4)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.goldDark,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    return SectionContainer(
      color: index.isOdd ? AppColors.softCream : AppColors.white,
      child: context.isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [image, const SizedBox(height: 38), copy],
            )
          : Row(
              children: reversed
                  ? [
                      Expanded(child: copy),
                      const SizedBox(width: 78),
                      Expanded(child: image),
                    ]
                  : [
                      Expanded(child: image),
                      const SizedBox(width: 78),
                      Expanded(child: copy),
                    ],
            ),
    );
  }
}

class _FeatureCta extends StatelessWidget {
  const _FeatureCta();

  @override
  Widget build(BuildContext context) => SectionContainer(
    color: AppColors.cream,
    child: Column(
      children: [
        Text(
          'A better business day starts here.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontSize: context.isMobile ? 42 : null,
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: 'Talk to our team',
          icon: Icons.arrow_outward_rounded,
          onPressed: () => context.go(AppRoutes.contact),
        ),
      ],
    ),
  );
}
