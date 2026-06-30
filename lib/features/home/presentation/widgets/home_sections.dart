import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:landing_groom_page/core/constants/app_constants.dart';
import 'package:landing_groom_page/core/utils/responsive.dart';
import 'package:landing_groom_page/core/widgets/app_button.dart';
import 'package:landing_groom_page/core/widgets/hover_surface.dart';
import 'package:landing_groom_page/core/widgets/reveal.dart';
import 'package:landing_groom_page/core/widgets/section_container.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
    super.key,
    this.centered = true,
    this.light = false,
  });

  final String eyebrow;
  final String title;
  final String description;
  final bool centered;
  final bool light;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start,
    children: [
      Text(
        eyebrow.toUpperCase(),
        textAlign: centered ? TextAlign.center : TextAlign.start,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.goldDark,
          fontSize: 11,
          letterSpacing: 1.6,
        ),
      ),
      const SizedBox(height: 14),
      Text(
        title,
        textAlign: centered ? TextAlign.center : TextAlign.start,
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
          color: light ? AppColors.white : AppColors.ink,
          fontSize: context.isMobile ? 43 : 56,
        ),
      ),
      const SizedBox(height: 18),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Text(
          description,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: light
                ? AppColors.white.withValues(alpha: .68)
                : AppColors.muted,
          ),
        ),
      ),
    ],
  );
}

class WhyGroomeSection extends StatelessWidget {
  const WhyGroomeSection({super.key});

  static const _items = [
    (
      Icons.calendar_month_outlined,
      '📍 Get Discovered',
      'Our salon appears in front of new and existing customers on the Groome app, helping you reach people actively looking to book nearby.',
    ),
    (
      Icons.groups_2_outlined,
      '📅 Instant Bookings',
      'Customers book appointments instantly through the Groome app, with automatic confirmations and reminders—eliminating phone calls and manual scheduling.',
    ),
    (
      Icons.chat_bubble_outline_rounded,
      '❤️ Customer Retention',
      'Keep customers coming back with automated reminders, personalized notifications, loyalty rewards, and exclusive offers through the Groome app.',
    ),
     (
      Icons.chat_bubble_outline_rounded,
      '📈 Business Dashboard',
      'Manage bookings, customers, appointments, staff, revenue, and business insights—all from one unified dashboard.',
    ),
     (
      Icons.chat_bubble_outline_rounded,
      '📢 Marketing',
      'Create offers, discounts, and promotions that are sent directly to your customers and featured on the Groome app to attract both new and returning customers.',

    ),
      (
      Icons.chat_bubble_outline_rounded,
      '👥 Customer CRM',
'Build a complete customer database with booking history, preferences, and visit records, helping you strengthen relationships, improve retention, and increase repeat bookings.',
    ),
  ];

  @override
  Widget build(BuildContext context) => SectionContainer(
    child: Column(
      children: [
        const Reveal(
          child: SectionHeading(
            eyebrow: 'Why Groome',
            title: 'Why salons choose Groome',
            description:
                'Less admin, fewer missed appointments, and more time for the work your customers love.',
          ),
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
                for (var i = 0; i < _items.length; i++)
                  SizedBox(
                    width: width,
                    child: Reveal(
                      delay: Duration(milliseconds: 90 * i),
                      child: HoverSurface(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: .14),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                _items[i].$1,
                                color: AppColors.goldDark,
                                size: 27,
                              ),
                            ),
                            const SizedBox(height: 26),
                            Text(
                              _items[i].$2,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _items[i].$3,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                            const Icon(
                              Icons.arrow_outward_rounded,
                              size: 20,
                              color: AppColors.ink,
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

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  static const _steps = [
    ('01', 'Customer discovers your salon on the Groome app', Icons.search_rounded),
    ('02', 'Books an appointment instantly', Icons.event_available_outlined),
    ('03', 'Groome confirms the booking automatically', Icons.trending_up_rounded),
        ('04', 'You manage everything from the Groome dashboard', Icons.dashboard_customize_rounded),
            ('05', 'Customers return through reminders, offers and loyalty rewards', Icons.stars_rounded),
  ];

  @override
  Widget build(BuildContext context) => SectionContainer(
    color: AppColors.softCream,
    child: Column(
      children: [
        const SectionHeading(
          eyebrow: 'How it works',
          title: 'How Groome Works',
          description:
              'A smooth, connected journey for your customers—and a calmer working day for you.',
        ),
        const SizedBox(height: 58),
        if (context.isMobile)
          for (var i = 0; i < _steps.length; i++) ...[
            _StepCard(step: _steps[i], index: i),
            if (i < _steps.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Icon(
                  Icons.arrow_downward_rounded,
                  color: AppColors.goldDark,
                ),
              ),
          ]
        else
          Row(
            children: [
              for (var i = 0; i < _steps.length; i++) ...[
                Expanded(
                  child: _StepCard(step: _steps[i], index: i),
                ),
                if (i < _steps.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.goldDark.withValues(alpha: .75),
                    ),
                  ),
              ],
            ],
          ),
      ],
    ),
  );
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step, required this.index});

  final (String, String, IconData) step;
  final int index;

  @override
  Widget build(BuildContext context) => Reveal(
    delay: Duration(milliseconds: 100 * index),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                step.$1,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.goldDark,
                  letterSpacing: 1.4,
                ),
              ),
              Icon(step.$3, color: AppColors.ink),
            ],
          ),
          const SizedBox(height: 44),
          Text(step.$2, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    ),
  );
}

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context) => SectionContainer(
    color: AppColors.ink,
    padding: EdgeInsets.symmetric(
      horizontal: context.pagePadding,
      vertical: context.isMobile ? 64 : 78,
    ),
    child: LayoutBuilder(
      builder: (context, constraints) => Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 28,
        runSpacing: 38,
        children: const [
          _Counter(value: 1000, suffix: '+', label: 'Appointments'),
          _Counter(value: 200, suffix: '+', label: 'Partner Salons'),
          _Counter(value: 95, suffix: '%', label: 'Customer Satisfaction'),
        ],
      ),
    ),
  );
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.value,
    required this.suffix,
    required this.label,
  });

  final int value;
  final String suffix;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: context.isMobile ? 260 : 280,
    child: TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1700),
      tween: Tween(begin: 0, end: value.toDouble()),
      curve: Curves.easeOutCubic,
      builder: (context, current, _) => Column(
        children: [
          Text(
            '${current.round()}$suffix',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppColors.gold,
              fontSize: context.isMobile ? 50 : 60,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.white.withValues(alpha: .68),
            ),
          ),
        ],
      ),
    ),
  );
}

class TestimonialsSection extends StatefulWidget {
  const TestimonialsSection({super.key});

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection> {
  final _controller = PageController(viewportFraction: .88);
  int _index = 0;

  static const _reviews = [
    (
      'Ananya Mehta',
      'Founder, Alora Studio',
      'Groome turned our appointment chaos into a system the whole team actually enjoys using. Our no-shows dropped in the first month.',
      AppAssets.salonConsultation,
    ),
    (
      'Rohan Kapoor',
      'Owner, North & Co.',
      'I finally know what is happening in my business without living in spreadsheets. The dashboard gives me the right answer in seconds.',
      AppAssets.salonOwner,
    ),
    (
      'Maya Fernandes',
      'Creative Director, Mysa',
      'Online booking feels effortless for our clients, and WhatsApp reminders save our front desk hours every week.',
      AppAssets.salonInterior,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SectionContainer(
    child: Column(
      children: [
        const SectionHeading(
          eyebrow: 'Customer stories',
          title: 'Loved by salon teams',
          description:
              'Real businesses using Groome to create better customer experiences.',
        ),
        const SizedBox(height: 50),
        SizedBox(
          height: context.isMobile ? 370 : 300,
          child: PageView.builder(
            controller: _controller,
            itemCount: _reviews.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 240),
                scale: _index == index ? 1 : .96,
                child: Container(
                  padding: EdgeInsets.all(context.isMobile ? 25 : 38),
                  decoration: BoxDecoration(
                    color: AppColors.softCream,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.star_rounded, color: AppColors.gold),
                          Icon(Icons.star_rounded, color: AppColors.gold),
                          Icon(Icons.star_rounded, color: AppColors.gold),
                          Icon(Icons.star_rounded, color: AppColors.gold),
                          Icon(Icons.star_rounded, color: AppColors.gold),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Text(
                          '“${_reviews[index].$3}”',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontSize: context.isMobile ? 17 : 21,
                                height: 1.55,
                              ),
                        ),
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: AssetImage(_reviews[index].$4),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _reviews[index].$1,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                Text(
                                  _reviews[index].$2,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _reviews.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: _index == index ? 24 : 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _index == index ? AppColors.ink : AppColors.line,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class HomeCtaSection extends StatelessWidget {
  const HomeCtaSection({super.key});

  @override
  Widget build(BuildContext context) => SectionContainer(
    color: AppColors.cream,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 26 : 72,
        vertical: context.isMobile ? 56 : 70,
      ),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(context.isMobile ? 24 : 36),
      ),
      child: context.isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ctaCopy(context),
                const SizedBox(height: 28),
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
                Expanded(child: _ctaCopy(context)),
                const SizedBox(width: 36),
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

  Widget _ctaCopy(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'READY WHEN YOU ARE',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.gold,
          fontSize: 11,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Grow your Salon with Groome?',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: AppColors.white,
          fontSize: context.isMobile ? 38 : 48,
        ),
      ),
    ],
  );
}
