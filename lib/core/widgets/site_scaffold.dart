import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:landing_groom_page/core/constants/app_constants.dart';
import 'package:landing_groom_page/core/content/site_content.dart';
import 'package:landing_groom_page/core/services/link_service.dart';
import 'package:landing_groom_page/core/utils/responsive.dart';
import 'package:landing_groom_page/core/widgets/app_button.dart';
import 'package:landing_groom_page/core/widgets/brand_logo.dart';

class SiteScaffold extends StatelessWidget {
  const SiteScaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: mobile ? 68 : 78,
        backgroundColor: AppColors.white.withValues(alpha: .96),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.ink.withValues(alpha: .08),
        automaticallyImplyLeading: false,
        titleSpacing: context.pagePadding,
        title: GestureDetector(
          onTap: () => context.go(AppRoutes.home),
          child: const BrandLogo(),
        ),
        actions: mobile
            ? [
                Builder(
                  builder: (context) => IconButton(
                    tooltip: 'Open menu',
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    icon: const Icon(Icons.menu_rounded),
                  ),
                ),
                const SizedBox(width: 12),
              ]
            : [
                _NavLink(label: 'Home', route: AppRoutes.home),
                _NavLink(label: 'About', route: AppRoutes.about),
                _NavLink(label: 'Features', route: AppRoutes.features),
                _NavLink(label: 'Contact', route: AppRoutes.contact),
                const SizedBox(width: 26),
                AppButton(
                  label: 'Contact us',
                  icon: Icons.arrow_outward_rounded,
                  onPressed: () => context.go(AppRoutes.contact),
                ),
                SizedBox(width: context.pagePadding),
              ],
      ),
      endDrawer: mobile ? const _MobileMenu() : null,
      body: SelectionArea(child: child),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.label, required this.route});

  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    final current = GoRouterState.of(context).uri.path;
    final selected = current == route;
    return TextButton(
      onPressed: () => context.go(route),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.ink,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(height: 5),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 18 : 0,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileMenu extends StatelessWidget {
  const _MobileMenu();

  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: AppColors.cream,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BrandLogo(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 42),
            for (final item in const [
              ('Home', AppRoutes.home),
              ('About', AppRoutes.about),
              ('Features', AppRoutes.features),
              ('Contact', AppRoutes.contact),
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  item.$1,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                trailing: const Icon(Icons.arrow_outward_rounded, size: 19),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(item.$2);
                },
              ),
            const Spacer(),
            AppButton(
              label: 'Contact us',
              expand: true,
              onPressed: () {
                Navigator.of(context).pop();
                context.go(AppRoutes.contact);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    const quickLinks = [
      _FooterRoute(label: 'About Us', route: AppRoutes.about),
      _FooterRoute(label: 'Features', route: AppRoutes.features),
      _FooterRoute(label: 'Contact', route: AppRoutes.contact),
    ];
    const policyLinks = [
      _FooterRoute(label: 'Privacy Policy', route: AppRoutes.privacyPolicy),
      _FooterRoute(
        label: 'Terms & Conditions',
        route: AppRoutes.termsConditions,
      ),
    ];

    return Container(
      color: AppColors.ink,
      padding: EdgeInsets.fromLTRB(
        context.pagePadding,
        mobile ? 56 : 72,
        context.pagePadding,
        28,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.contentMax,
          ),
          child: Column(
            children: [
              if (mobile)
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FooterBrand(),
                    SizedBox(height: 34),
                    _FooterLinkColumn(title: 'Quick Links', links: quickLinks),
                    SizedBox(height: 30),
                    _FooterLinkColumn(title: 'Policies', links: policyLinks),
                    SizedBox(height: 30),
                    _FooterContactColumn(),
                  ],
                )
              else
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: _FooterBrand()),
                    SizedBox(width: 58),
                    Expanded(
                      flex: 2,
                      child: _FooterLinkColumn(
                        title: 'Quick Links',
                        links: quickLinks,
                      ),
                    ),
                    SizedBox(width: 32),
                    Expanded(
                      flex: 2,
                      child: _FooterLinkColumn(
                        title: 'Policies',
                        links: policyLinks,
                      ),
                    ),
                    SizedBox(width: 32),
                    Expanded(flex: 3, child: _FooterContactColumn()),
                  ],
                ),
              const SizedBox(height: 44),
              Divider(color: AppColors.white.withValues(alpha: .14)),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Copyright ${DateFormat('yyyy').format(DateTime.now())} Groome. All rights reserved.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: .58),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (!mobile)
                    Text(
                      'Built for better salon days.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: .58),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterRoute {
  const _FooterRoute({required this.label, required this.route});

  final String label;
  final String route;
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const BrandLogo(light: true),
      const SizedBox(height: 24),
      Text(
        SiteContent.footerSummary,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.white.withValues(alpha: .7),
        ),
      ),
      const SizedBox(height: 24),
      for (final item in SiteContent.footerHighlights)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.gold,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.white.withValues(alpha: .82),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class _FooterLinkColumn extends StatelessWidget {
  const _FooterLinkColumn({required this.title, required this.links});

  final String title;
  final List<_FooterRoute> links;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _FooterTitle(title),
      const SizedBox(height: 20),
      for (final link in links)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _FooterLink(
            label: link.label,
            onTap: () => context.go(link.route),
          ),
        ),
    ],
  );
}

class _FooterTitle extends StatelessWidget {
  const _FooterTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(color: AppColors.white, fontSize: 17),
  );
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.white.withValues(alpha: .72),
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _FooterContactColumn extends StatelessWidget {
  const _FooterContactColumn();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _FooterTitle('Get In Touch'),
      const SizedBox(height: 20),
      _ContactMethod(
        icon: Icons.call_outlined,
        title: 'Call Us',
        value: SiteContent.phone,
        onTap: () => LinkService.open(SiteContent.phoneUrl),
      ),
      const SizedBox(height: 14),
      _ContactMethod(
        icon: Icons.mail_outline_rounded,
        title: 'Email Us',
        value: SiteContent.supportEmail,
        onTap: () => LinkService.open(SiteContent.supportEmailUrl),
      ),
      const SizedBox(height: 24),
      Divider(color: AppColors.white.withValues(alpha: .14)),
      const SizedBox(height: 18),
      Text(
        'Follow Us',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AppColors.white),
      ),
      const SizedBox(height: 14),
      const _SocialLinks(),
    ],
  );
}

class _ContactMethod extends StatelessWidget {
  const _ContactMethod({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.gold, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.white),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withValues(alpha: .7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SocialLinks extends StatelessWidget {
  const _SocialLinks();

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: 10,
    runSpacing: 10,
    children: [
      _SocialIcon(
        label: 'Instagram',
        handle: SiteContent.instagramHandle,
        icon: Icons.camera_alt_outlined,
        url: SiteContent.instagramUrl,
      ),
      _SocialIcon(
        label: 'LinkedIn',
        handle: SiteContent.linkedInHandle,
        icon: Icons.work_outline_rounded,
        url: SiteContent.linkedInUrl,
      ),
      _SocialIcon(
        label: 'YouTube',
        handle: SiteContent.youtubeHandle,
        icon: Icons.play_arrow_rounded,
        url: SiteContent.youtubeUrl,
      ),
      _SocialIcon(
        label: 'X',
        handle: SiteContent.xHandle,
        icon: Icons.alternate_email_rounded,
        url: SiteContent.xUrl,
      ),
    ],
  );
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({
    required this.label,
    required this.handle,
    required this.icon,
    required this.url,
  });

  final String label;
  final String handle;
  final IconData icon;
  final String url;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: '$label $handle',
    child: InkWell(
      onTap: () => LinkService.open(url),
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: .08),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white.withValues(alpha: .08)),
        ),
        child: Icon(icon, size: 20, color: AppColors.white),
      ),
    ),
  );
}
