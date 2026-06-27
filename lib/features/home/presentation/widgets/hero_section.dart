import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:landing_groom_page/core/constants/app_constants.dart';
import 'package:landing_groom_page/core/utils/responsive.dart';
import 'package:landing_groom_page/core/widgets/app_button.dart';
import 'package:landing_groom_page/core/widgets/reveal.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    final copy = Reveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'Now onboarding salon partners in Delhi NCR',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.goldDark,
                fontSize: 11,
                letterSpacing: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Skip the wait.\nBook your salon instantly.',
            style:
                (mobile
                        ? Theme.of(context).textTheme.displayMedium
                        : Theme.of(context).textTheme.displayLarge)
                    ?.copyWith(fontSize: mobile ? 55 : null),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Text(
              'Grow bookings, manage customers and take your business digital with Groome.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontSize: mobile ? 16 : 18),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton(
                label: 'Get started',
                icon: Icons.arrow_outward_rounded,
                onPressed: () => context.go(AppRoutes.contact),
              ),
              AppButton(
                label: 'Contact us',
                outlined: true,
                onPressed: () => context.go(AppRoutes.contact),
              ),
            ],
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final icon in [
                Icons.calendar_month_outlined,
                Icons.people_outline_rounded,
                Icons.trending_up_rounded,
              ])
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 17, color: AppColors.ink),
                ),
              const SizedBox(width: 6),
              Text(
                'Built for ambitious salon owners',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Container(
      color: AppColors.cream,
      padding: EdgeInsets.fromLTRB(
        context.pagePadding,
        mobile ? 54 : 70,
        context.pagePadding,
        mobile ? 70 : 96,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.contentMax,
          ),
          child: mobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    copy,
                    const SizedBox(height: 48),
                    const Reveal(
                      delay: Duration(milliseconds: 180),
                      child: SalonCarousel(height: 410),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 10, child: copy),
                    const SizedBox(width: 62),
                    const Expanded(
                      flex: 11,
                      child: Reveal(
                        delay: Duration(milliseconds: 180),
                        child: SalonCarousel(height: 590),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class SalonCarousel extends StatefulWidget {
  const SalonCarousel({required this.height, super.key});

  final double height;

  @override
  State<SalonCarousel> createState() => _SalonCarouselState();
}

class _SalonCarouselState extends State<SalonCarousel> {
  late final PageController _controller;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_controller.hasClients) return;
      final next = (_index + 1) % AppAssets.salonImages.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: widget.height,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          right: -16,
          top: 22,
          bottom: -18,
          left: 24,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: PageView.builder(
            controller: _controller,
            itemCount: AppAssets.salonImages.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (_, index) => Hero(
              tag: 'salon-image-$index',
              child: Image.asset(
                AppAssets.salonImages[index],
                fit: BoxFit.cover,
                semanticLabel: 'Modern salon experience',
              ),
            ),
          ),
        ),
        Positioned(
          left: 22,
          bottom: 22,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.ink.withValues(alpha: .86),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              children: List.generate(
                AppAssets.salonImages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: index == _index ? 22 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index == _index
                        ? AppColors.gold
                        : AppColors.white.withValues(alpha: .55),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 18,
          top: 18,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: .94),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Row(
              children: [
                Icon(Icons.bolt_rounded, color: AppColors.goldDark, size: 18),
                SizedBox(width: 6),
                Text('Simple. Smart. Groome.'),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
