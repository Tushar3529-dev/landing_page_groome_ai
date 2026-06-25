import 'package:flutter/material.dart';
import 'package:landing_groom_page/core/constants/app_constants.dart';
import 'package:landing_groom_page/core/content/site_content.dart';
import 'package:landing_groom_page/core/utils/responsive.dart';
import 'package:landing_groom_page/core/widgets/section_container.dart';
import 'package:landing_groom_page/core/widgets/site_scaffold.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({required this.document, super.key});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) => SiteScaffold(
    child: SingleChildScrollView(
      child: Column(
        children: [
          _LegalHero(document: document),
          _LegalBody(document: document),
          const SiteFooter(),
        ],
      ),
    ),
  );
}

class _LegalHero extends StatelessWidget {
  const _LegalHero({required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) => SectionContainer(
    color: AppColors.cream,
    padding: EdgeInsets.fromLTRB(
      context.pagePadding,
      context.isMobile ? 64 : 92,
      context.pagePadding,
      context.isMobile ? 64 : 96,
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            document.eyebrow.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.goldDark,
              fontSize: 11,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            document.title,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 22),
          Text(document.summary, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _DatePill(label: 'Effective', value: document.effectiveDate),
              _DatePill(label: 'Updated', value: document.lastUpdated),
            ],
          ),
        ],
      ),
    ),
  );
}

class _DatePill extends StatelessWidget {
  const _DatePill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: AppColors.line),
    ),
    child: Text(
      '$label: $value',
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(color: AppColors.ink, fontSize: 12),
    ),
  );
}

class _LegalBody extends StatelessWidget {
  const _LegalBody({required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) => SectionContainer(
    padding: EdgeInsets.fromLTRB(
      context.pagePadding,
      context.isMobile ? 56 : 78,
      context.pagePadding,
      context.isMobile ? 64 : 96,
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < document.sections.length; i++) ...[
            _LegalSectionView(section: document.sections[i]),
            if (i < document.sections.length - 1)
              Divider(
                height: context.isMobile ? 42 : 54,
                color: AppColors.line,
              ),
          ],
        ],
      ),
    ),
  );
}

class _LegalSectionView extends StatelessWidget {
  const _LegalSectionView({required this.section});

  final LegalSection section;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(section.title, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 14),
      for (final paragraph in section.paragraphs) ...[
        Text(paragraph, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
      ],
      if (section.bullets.isNotEmpty) ...[
        const SizedBox(height: 4),
        for (final bullet in section.bullets)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(top: 10, right: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.goldDark,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    bullet,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.ink.withValues(alpha: .78),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ],
  );
}
