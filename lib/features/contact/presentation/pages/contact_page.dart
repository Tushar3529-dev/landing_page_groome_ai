import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landing_groom_page/core/constants/app_constants.dart';
import 'package:landing_groom_page/core/utils/responsive.dart';
import 'package:landing_groom_page/core/widgets/app_button.dart';
import 'package:landing_groom_page/core/widgets/reveal.dart';
import 'package:landing_groom_page/core/widgets/section_container.dart';
import 'package:landing_groom_page/core/widgets/site_scaffold.dart';
import 'package:landing_groom_page/features/contact/domain/entities/contact_lead.dart';
import 'package:landing_groom_page/features/contact/presentation/cubit/contact_cubit.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) => const SiteScaffold(
    child: SingleChildScrollView(
      child: Column(children: [_ContactContent(), SiteFooter()]),
    ),
  );
}

class _ContactContent extends StatelessWidget {
  const _ContactContent();

  @override
  Widget build(BuildContext context) => SectionContainer(
    color: AppColors.cream,
    padding: EdgeInsets.fromLTRB(
      context.pagePadding,
      context.isMobile ? 62 : 92,
      context.pagePadding,
      context.isMobile ? 78 : 116,
    ),
    child: context.isMobile
        ? const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Reveal(child: _ContactIntro()),
              SizedBox(height: 42),
              Reveal(
                delay: Duration(milliseconds: 130),
                child: ContactFormCard(),
              ),
            ],
          )
        : const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: Reveal(child: _ContactIntro())),
              SizedBox(width: 76),
              Expanded(
                flex: 6,
                child: Reveal(
                  delay: Duration(milliseconds: 130),
                  child: ContactFormCard(),
                ),
              ),
            ],
          ),
  );
}

class _ContactIntro extends StatelessWidget {
  const _ContactIntro();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'CONTACT',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.goldDark,
          fontSize: 11,
          letterSpacing: 1.6,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        "Let's Talk",
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
          fontSize: context.isMobile ? 58 : 74,
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'Tell us about your salon and what a better working day looks like. We’ll show you how Groome can help.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 42),
      const _Promise(
        icon: Icons.schedule_rounded,
        title: 'Quick response',
        body: 'Our team usually replies within one business day.',
      ),
      const SizedBox(height: 22),
      const _Promise(
        icon: Icons.forum_outlined,
        title: 'A real conversation',
        body: 'No hard sell—just practical answers for your business.',
      ),
      const SizedBox(height: 22),
      const _Promise(
        icon: Icons.lock_outline_rounded,
        title: 'Your details stay private',
        body: 'We only use them to respond to your enquiry.',
      ),
    ],
  );
}

class _Promise extends StatelessWidget {
  const _Promise({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, size: 21, color: AppColors.goldDark),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 3),
            Text(
              body,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    ],
  );
}

class ContactFormCard extends StatefulWidget {
  const ContactFormCard({super.key});

  @override
  State<ContactFormCard> createState() => _ContactFormCardState();
}

class _ContactFormCardState extends State<ContactFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _business = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _business.dispose();
    _message.dispose();
    super.dispose();
  }

  void _clear() {
    _formKey.currentState?.reset();
    _name.clear();
    _email.clear();
    _phone.clear();
    _business.clear();
    _message.clear();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<ContactCubit>().submit(
      ContactLead(
        name: _name.text,
        email: _email.text,
        phone: _phone.text,
        businessName: _business.text,
        message: _message.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<ContactCubit, ContactState>(
        listener: (context, state) {
          if (state is ContactSuccess) {
            _clear();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Thank you! Our team will contact you soon.'),
                ),
              );
            context.read<ContactCubit>().reset();
          } else if (state is ContactFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final loading = state is ContactLoading;
          return Container(
            padding: EdgeInsets.all(context.isMobile ? 24 : 38),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.line),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: .07),
                  blurRadius: 40,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tell us about your business',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All fields are required.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  _Field(
                    controller: _name,
                    label: 'Full Name',
                    hint: 'Your full name',
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        _required(value, 'Enter your full name'),
                  ),
                  const SizedBox(height: 18),
                  _Field(
                    controller: _email,
                    label: 'Email Address',
                    hint: 'you@business.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final clean = value?.trim() ?? '';
                      if (clean.isEmpty) return 'Enter your email address';
                      final valid = RegExp(
                        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                      ).hasMatch(clean);
                      return valid ? null : 'Enter a valid email address';
                    },
                  ),
                  const SizedBox(height: 18),
                  _Field(
                    controller: _phone,
                    label: 'Phone Number',
                    hint: '+91 98765 43210',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final clean = (value ?? '').replaceAll(RegExp(r'\D'), '');
                      if (clean.isEmpty) return 'Enter your phone number';
                      return clean.length >= 8
                          ? null
                          : 'Enter a valid phone number';
                    },
                  ),
                  const SizedBox(height: 18),
                  _Field(
                    controller: _business,
                    label: 'Business Name',
                    hint: 'Your salon or studio',
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        _required(value, 'Enter your business name'),
                  ),
                  const SizedBox(height: 18),
                  _Field(
                    controller: _message,
                    label: 'Message',
                    hint: 'What would you like help with?',
                    minLines: 4,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                    validator: (value) {
                      final clean = value?.trim() ?? '';
                      if (clean.isEmpty) return 'Enter a short message';
                      return clean.length >= 10
                          ? null
                          : 'Please add a little more detail';
                    },
                  ),
                  const SizedBox(height: 26),
                  AppButton(
                    label: 'Contact Us',
                    expand: true,
                    loading: loading,
                    icon: Icons.arrow_outward_rounded,
                    onPressed: loading ? null : _submit,
                  ),
                ],
              ),
            ),
          );
        },
      );

  static String? _required(String? value, String message) =>
      (value?.trim().isEmpty ?? true) ? message : null;
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
    required this.textInputAction,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        minLines: minLines,
        maxLines: maxLines,
        enabled: context.watch<ContactCubit>().state is! ContactLoading,
        decoration: InputDecoration(hintText: hint),
      ),
    ],
  );
}
