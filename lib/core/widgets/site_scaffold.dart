import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:landing_groom_page/core/constants/app_constants.dart';
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
    final links = Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _FooterLink(label: 'Home', onTap: () => context.go(AppRoutes.home)),
        _FooterLink(
          label: 'Features',
          onTap: () => context.go(AppRoutes.features),
        ),
        _FooterLink(
          label: 'Contact',
          onTap: () => context.go(AppRoutes.contact),
        ),
      ],
    );

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandLogo(light: true),
                    const SizedBox(height: 28),
                    links,
                    const SizedBox(height: 26),
                    const _SocialLinks(),
                  ],
                )
              else
                Row(
                  children: [
                    const BrandLogo(light: true),
                    const Spacer(),
                    links,
                    const Spacer(),
                    const _SocialLinks(),
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
                      '© ${DateFormat('yyyy').format(DateTime.now())} Groome. All rights reserved.',
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

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(foregroundColor: AppColors.white),
    child: Text(label),
  );
}

class _SocialLinks extends StatelessWidget {
  const _SocialLinks();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _SocialIcon(
        label: 'Instagram',
        icon: Icons.camera_alt_outlined,
        onTap: () => LinkService.open('https://instagram.com'),
      ),
      _SocialIcon(
        label: 'LinkedIn',
        icon: Icons.work_outline_rounded,
        onTap: () => LinkService.open('https://linkedin.com'),
      ),
      _SocialIcon(
        label: 'WhatsApp',
        icon: Icons.chat_bubble_outline_rounded,
        onTap: () => LinkService.open('https://wa.me/'),
      ),
    ],
  );
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: label,
    onPressed: onTap,
    color: AppColors.white,
    icon: Icon(icon, size: 20),
  );
}
