import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:landing_groom_page/core/constants/app_constants.dart';
import 'package:landing_groom_page/core/utils/responsive.dart';
import 'package:landing_groom_page/core/widgets/app_button.dart';
import 'package:landing_groom_page/core/widgets/brand_logo.dart';
import 'package:landing_groom_page/core/widgets/site_scaffold.dart';
import 'package:landing_groom_page/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:landing_groom_page/features/dashboard/presentation/controllers/dashboard_controller.dart';

enum DashboardSection {
  overview,
  calendar,
  bookings,
  clients,
  salons,
  team,
  services,
  analytics,
  settings,
  admins,
}

enum BookingFilter { all, confirmed, cancelled }

extension DashboardSectionData on DashboardSection {
  String get label => switch (this) {
    DashboardSection.overview => 'Overview',
    DashboardSection.calendar => 'Calendar',
    DashboardSection.bookings => 'Bookings',
    DashboardSection.clients => 'Clients',
    DashboardSection.salons => 'Salons',
    DashboardSection.team => 'Team',
    DashboardSection.services => 'Services',
    DashboardSection.analytics => 'Analytics',
    DashboardSection.settings => 'Settings',
    DashboardSection.admins => 'Admins',
  };

  IconData get icon => switch (this) {
    DashboardSection.overview => Icons.dashboard_customize_outlined,
    DashboardSection.calendar => Icons.calendar_month_outlined,
    DashboardSection.bookings => Icons.event_note_outlined,
    DashboardSection.clients => Icons.contacts_outlined,
    DashboardSection.salons => Icons.storefront_outlined,
    DashboardSection.team => Icons.groups_2_outlined,
    DashboardSection.services => Icons.content_cut_rounded,
    DashboardSection.analytics => Icons.analytics_outlined,
    DashboardSection.settings => Icons.tune_rounded,
    DashboardSection.admins => Icons.admin_panel_settings_outlined,
  };

  bool visibleFor(DashboardRole role) =>
      this != DashboardSection.admins || role == DashboardRole.superAdmin;
}

class DashboardLoginPage extends StatefulWidget {
  const DashboardLoginPage({super.key});

  @override
  State<DashboardLoginPage> createState() => _DashboardLoginPageState();
}

class _DashboardLoginPageState extends State<DashboardLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    groomeDashboardStore.initialize();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final result = await groomeDashboardStore.signIn(
      _email.text,
      _password.text,
    );
    if (!mounted) return;

    setState(() => _loading = false);
    if (result.success) {
      context.go(AppRoutes.dashboard);
      return;
    }

    setState(() => _error = result.message);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: groomeDashboardStore,
    builder: (context, _) {
      if (groomeDashboardStore.currentUser != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go(AppRoutes.dashboard);
        });
      }

      final mobile = context.isMobile;
      final loginCard = _LoginCard(
        formKey: _formKey,
        email: _email,
        password: _password,
        obscure: _obscure,
        loading: _loading,
        error: _error,
        onTogglePassword: () => setState(() => _obscure = !_obscure),
        onSubmit: _submit,
      );

      return SiteScaffold(
        child: ColoredBox(
          color: AppColors.cream,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                context.pagePadding,
                mobile ? 54 : 84,
                context.pagePadding,
                mobile ? 70 : 112,
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
                            const _LoginIntro(),
                            const SizedBox(height: 34),
                            loginCard,
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(flex: 5, child: _LoginIntro()),
                            const SizedBox(width: 72),
                            Expanded(flex: 4, child: loginCard),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _LoginIntro extends StatelessWidget {
  const _LoginIntro();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'PARTNER DASHBOARD',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.goldDark,
          fontSize: 11,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 18),
      Text(
        'Manage every salon day from one calm workspace.',
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
          fontSize: context.isMobile ? 45 : 58,
        ),
      ),
      const SizedBox(height: 22),
      Text(
        'Access is created by the Groome Super Admin. Salon partners use the email and password shared with them after subscription payment is collected offline.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 32),
      const Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _LoginPill(icon: Icons.storefront_outlined, label: 'Multi-salon'),
          _LoginPill(icon: Icons.groups_2_outlined, label: 'Team'),
          _LoginPill(icon: Icons.event_note_outlined, label: 'Bookings'),
          _LoginPill(icon: Icons.admin_panel_settings_outlined, label: 'Admin'),
        ],
      ),
    ],
  );
}

class _LoginPill extends StatelessWidget {
  const _LoginPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: AppColors.line),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: AppColors.goldDark),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
      ],
    ),
  );
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.email,
    required this.password,
    required this.obscure,
    required this.loading,
    required this.onTogglePassword,
    required this.onSubmit,
    this.error,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final bool obscure;
  final bool loading;
  final String? error;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(context.isMobile ? 24 : 34),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: AppColors.line),
      boxShadow: [
        BoxShadow(
          color: AppColors.ink.withValues(alpha: .08),
          blurRadius: 42,
          offset: const Offset(0, 18),
        ),
      ],
    ),
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Login', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Only existing partner accounts can enter.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          TextFormField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter your email';
              }
              if (!value.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: password,
            obscureText: obscure,
            onFieldSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: obscure ? 'Show password' : 'Hide password',
                onPressed: onTogglePassword,
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter your password';
              }
              return null;
            },
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFC9C5)),
              ),
              child: Text(
                error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFB42318),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          AppButton(
            label: 'Log in',
            loading: loading,
            expand: true,
            icon: Icons.login_rounded,
            onPressed: loading ? null : onSubmit,
          ),
        ],
      ),
    ),
  );
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardSection _section = DashboardSection.overview;
  BookingFilter _bookingFilter = BookingFilter.all;
  String? _selectedSalonId;
  String _clientQuery = '';
  String _teamFilter = 'all';
  bool _weekMode = false;

  @override
  void initState() {
    super.initState();
    groomeDashboardStore.initialize();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: groomeDashboardStore,
    builder: (context, _) {
      final user = groomeDashboardStore.currentUser;
      if (user == null) {
        if (groomeDashboardStore.authChecked) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(AppRoutes.dashboardLogin);
          });
        }
        return const Scaffold(
          backgroundColor: AppColors.cream,
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (!_section.visibleFor(user.role)) {
        _section = DashboardSection.overview;
      }

      final salon = _selectedSalon(groomeDashboardStore);
      final mobile = context.isMobile;
      final body = _DashboardContent(
        title: _section.label,
        user: user,
        selectedSalon: salon,
        selectedSalonId: salon?.id,
        onSalonChanged: (value) => setState(() => _selectedSalonId = value),
        child: _buildSection(user, salon),
      );

      if (mobile) {
        return Scaffold(
          backgroundColor: AppColors.softCream,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            title: const BrandLogo(),
            actions: [
              IconButton(
                tooltip: 'Logout',
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          drawer: _DashboardDrawer(
            user: user,
            selected: _section,
            onSelected: (section) {
              Navigator.of(context).pop();
              setState(() => _section = section);
            },
            onLogout: _logout,
          ),
          body: body,
        );
      }

      return Scaffold(
        backgroundColor: AppColors.softCream,
        body: Row(
          children: [
            _DashboardSidebar(
              user: user,
              selected: _section,
              onSelected: (section) => setState(() => _section = section),
              onLogout: _logout,
            ),
            Expanded(child: body),
          ],
        ),
      );
    },
  );

  Widget _buildSection(DashboardUser user, SalonProfile? salon) {
    if (salon == null && _section != DashboardSection.admins) {
      return _EmptyState(
        icon: Icons.storefront_outlined,
        title: 'No salon connected',
        body:
            'Create a salon branch before adding team, services, and bookings.',
        actionLabel: 'Add Salon',
        onAction: () => _showAddSalonDialog(user),
      );
    }

    return switch (_section) {
      DashboardSection.overview => _OverviewSection(
        salon: salon!,
        store: groomeDashboardStore,
        onAddBooking: () => _showAddBookingDialog(salon),
        onAddService: () => _showAddServiceDialog(salon),
        onShowBookings: () =>
            setState(() => _section = DashboardSection.bookings),
      ),
      DashboardSection.calendar => _CalendarSection(
        salon: salon!,
        store: groomeDashboardStore,
        weekMode: _weekMode,
        teamFilter: _teamFilter,
        onModeChanged: (value) => setState(() => _weekMode = value),
        onTeamFilterChanged: (value) => setState(() => _teamFilter = value),
        onAddBooking: () => _showAddBookingDialog(salon),
      ),
      DashboardSection.bookings => _BookingsSection(
        salon: salon!,
        store: groomeDashboardStore,
        filter: _bookingFilter,
        onFilterChanged: (filter) => setState(() => _bookingFilter = filter),
        onAddBooking: () => _showAddBookingDialog(salon),
      ),
      DashboardSection.clients => _ClientsSection(
        salon: salon!,
        store: groomeDashboardStore,
        query: _clientQuery,
        onQueryChanged: (value) => setState(() => _clientQuery = value),
      ),
      DashboardSection.salons => _SalonsSection(
        user: user,
        store: groomeDashboardStore,
        onAddSalon: () => _showAddSalonDialog(user),
        onEditSalon: _showEditSalonDialog,
      ),
      DashboardSection.team => _TeamSection(
        salon: salon!,
        store: groomeDashboardStore,
        onAddMember: () => _showAddMemberDialog(salon),
      ),
      DashboardSection.services => _ServicesSection(
        salon: salon!,
        store: groomeDashboardStore,
        onAddService: () => _showAddServiceDialog(salon),
      ),
      DashboardSection.analytics => _AnalyticsSection(
        salon: salon!,
        store: groomeDashboardStore,
      ),
      DashboardSection.settings => _SettingsSection(
        salon: salon!,
        store: groomeDashboardStore,
        onEditSalon: () => _showEditSalonDialog(salon),
      ),
      DashboardSection.admins => _AdminsSection(
        store: groomeDashboardStore,
        onCreateAdmin: _showCreateAdminDialog,
        onEditPassword: _showPasswordDialog,
      ),
    };
  }

  SalonProfile? _selectedSalon(DashboardController store) {
    final salons = store.visibleSalons;
    if (salons.isEmpty) return null;
    for (final salon in salons) {
      if (salon.id == _selectedSalonId) return salon;
    }
    _selectedSalonId = salons.first.id;
    return salons.first;
  }

  Future<void> _logout() async {
    await groomeDashboardStore.logout();
    if (!mounted) return;
    context.go(AppRoutes.dashboardLogin);
  }

  Future<void> _showAddSalonDialog(DashboardUser user) async {
    final name = TextEditingController();
    final locality = TextEditingController(text: 'New Delhi');
    final address = TextEditingController();
    final phone = TextEditingController(text: '+91 ');
    final email = TextEditingController(text: user.email);
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _FormDialog(
        title: 'Add Salon',
        actionLabel: 'Save Salon',
        formKey: formKey,
        onSubmit: () async {
          if (!(formKey.currentState?.validate() ?? false)) return;
          await groomeDashboardStore.addSalon(
            ownerUserId: user.role == DashboardRole.superAdmin
                ? groomeDashboardStore.users
                      .firstWhere(
                        (candidate) =>
                            candidate.role == DashboardRole.salonAdmin,
                      )
                      .id
                : user.id,
            name: name.text.trim(),
            locality: locality.text.trim(),
            address: address.text.trim(),
            phone: phone.text.trim(),
            email: email.text.trim(),
          );
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        },
        children: [
          _DialogField(controller: name, label: 'Salon name'),
          _DialogField(controller: locality, label: 'Locality'),
          _DialogField(controller: address, label: 'Address'),
          _DialogField(controller: phone, label: 'Phone'),
          _DialogField(controller: email, label: 'Email'),
        ],
      ),
    );

    name.dispose();
    locality.dispose();
    address.dispose();
    phone.dispose();
    email.dispose();
  }

  Future<void> _showEditSalonDialog(SalonProfile salon) async {
    final name = TextEditingController(text: salon.name);
    final locality = TextEditingController(text: salon.locality);
    final address = TextEditingController(text: salon.address);
    final phone = TextEditingController(text: salon.phone);
    final email = TextEditingController(text: salon.email);
    final about = TextEditingController(text: salon.about);
    final opening = TextEditingController(text: salon.openingTime);
    final closing = TextEditingController(text: salon.closingTime);
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _FormDialog(
        title: 'Edit Salon Profile',
        actionLabel: 'Save Changes',
        formKey: formKey,
        onSubmit: () async {
          if (!(formKey.currentState?.validate() ?? false)) return;
          await groomeDashboardStore.updateSalon(
            SalonProfile(
              id: salon.id,
              ownerUserId: salon.ownerUserId,
              name: name.text.trim(),
              locality: locality.text.trim(),
              address: address.text.trim(),
              phone: phone.text.trim(),
              email: email.text.trim(),
              about: about.text.trim(),
              openingTime: opening.text.trim(),
              closingTime: closing.text.trim(),
              acceptingBookings: salon.acceptingBookings,
            ),
          );
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        },
        children: [
          _DialogField(controller: name, label: 'Salon name'),
          _DialogField(controller: locality, label: 'Locality'),
          _DialogField(controller: address, label: 'Address'),
          _DialogField(controller: phone, label: 'Phone'),
          _DialogField(controller: email, label: 'Email'),
          _DialogField(controller: about, label: 'About', maxLines: 3),
          Row(
            children: [
              Expanded(
                child: _DialogField(controller: opening, label: 'Opening'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DialogField(controller: closing, label: 'Closing'),
              ),
            ],
          ),
        ],
      ),
    );

    name.dispose();
    locality.dispose();
    address.dispose();
    phone.dispose();
    email.dispose();
    about.dispose();
    opening.dispose();
    closing.dispose();
  }

  Future<void> _showAddMemberDialog(SalonProfile salon) async {
    final name = TextEditingController();
    final role = TextEditingController();
    final experience = TextEditingController(text: '3 years');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _FormDialog(
        title: 'Add Team Member',
        actionLabel: 'Add Member',
        formKey: formKey,
        onSubmit: () async {
          if (!(formKey.currentState?.validate() ?? false)) return;
          await groomeDashboardStore.addTeamMember(
            salonId: salon.id,
            name: name.text.trim(),
            role: role.text.trim(),
            experience: experience.text.trim(),
          );
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        },
        children: [
          _DialogField(controller: name, label: 'Full name'),
          _DialogField(controller: role, label: 'Role'),
          _DialogField(controller: experience, label: 'Experience'),
        ],
      ),
    );

    name.dispose();
    role.dispose();
    experience.dispose();
  }

  Future<void> _showAddServiceDialog(SalonProfile salon) async {
    final name = TextEditingController();
    final category = TextEditingController(text: 'Hair');
    final duration = TextEditingController(text: '30');
    final price = TextEditingController(text: '399');
    final formKey = GlobalKey<FormState>();
    final selectedTeam = <String>{
      for (final member in groomeDashboardStore.teamFor(salon.id))
        if (member.active) member.id,
    };

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => _FormDialog(
          title: 'Add Service',
          actionLabel: 'Add Service',
          formKey: formKey,
          onSubmit: () async {
            if (!(formKey.currentState?.validate() ?? false)) return;
            await groomeDashboardStore.addService(
              salonId: salon.id,
              name: name.text.trim(),
              category: category.text.trim(),
              durationMinutes: int.tryParse(duration.text.trim()) ?? 30,
              price: int.tryParse(price.text.trim()) ?? 0,
              teamMemberIds: selectedTeam.toList(),
            );
            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          },
          children: [
            _DialogField(controller: name, label: 'Service name'),
            _DialogField(controller: category, label: 'Category'),
            Row(
              children: [
                Expanded(
                  child: _DialogField(
                    controller: duration,
                    label: 'Duration minutes',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogField(
                    controller: price,
                    label: 'Price',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            Text(
              'Assign team members',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            for (final member in groomeDashboardStore.teamFor(salon.id))
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: selectedTeam.contains(member.id),
                title: Text(member.name),
                subtitle: Text(member.role),
                onChanged: (value) => setDialogState(() {
                  if (value ?? false) {
                    selectedTeam.add(member.id);
                  } else {
                    selectedTeam.remove(member.id);
                  }
                }),
              ),
          ],
        ),
      ),
    );

    name.dispose();
    category.dispose();
    duration.dispose();
    price.dispose();
  }

  Future<void> _showAddBookingDialog(SalonProfile salon) async {
    final services = groomeDashboardStore.servicesFor(salon.id);
    final team = groomeDashboardStore
        .teamFor(salon.id)
        .where((m) => m.active)
        .toList();
    if (services.isEmpty || team.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add at least one active team member and service first.',
          ),
        ),
      );
      return;
    }

    final customer = TextEditingController();
    final phone = TextEditingController(text: '+91 ');
    final date = TextEditingController(text: groomeDashboardStore.today);
    final time = TextEditingController(text: '04:30 PM');
    final formKey = GlobalKey<FormState>();
    var selectedServiceId = services.first.id;
    var selectedTeamId = services.first.teamMemberIds.isNotEmpty
        ? services.first.teamMemberIds.first
        : team.first.id;
    var source = 'Manual';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => _FormDialog(
          title: 'New Appointment',
          actionLabel: 'Save Booking',
          formKey: formKey,
          onSubmit: () async {
            if (!(formKey.currentState?.validate() ?? false)) return;
            await groomeDashboardStore.addBooking(
              salonId: salon.id,
              customerName: customer.text.trim(),
              customerPhone: phone.text.trim(),
              serviceId: selectedServiceId,
              teamMemberId: selectedTeamId,
              date: date.text.trim(),
              time: time.text.trim(),
              source: source,
            );
            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          },
          children: [
            _DialogField(controller: phone, label: 'Customer phone'),
            _DialogField(controller: customer, label: 'Customer name'),
            DropdownButtonFormField<String>(
              initialValue: selectedServiceId,
              decoration: const InputDecoration(labelText: 'Service'),
              items: [
                for (final service in services)
                  DropdownMenuItem(
                    value: service.id,
                    child: Text('${service.name} - Rs ${service.price}'),
                  ),
              ],
              onChanged: (value) => setDialogState(() {
                selectedServiceId = value ?? selectedServiceId;
                final service = groomeDashboardStore.serviceById(
                  selectedServiceId,
                );
                if (service != null && service.teamMemberIds.isNotEmpty) {
                  selectedTeamId = service.teamMemberIds.first;
                }
              }),
            ),
            DropdownButtonFormField<String>(
              initialValue: selectedTeamId,
              decoration: const InputDecoration(labelText: 'Stylist'),
              items: [
                for (final member in team)
                  DropdownMenuItem(value: member.id, child: Text(member.name)),
              ],
              onChanged: (value) => setDialogState(
                () => selectedTeamId = value ?? selectedTeamId,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _DialogField(controller: date, label: 'Date'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogField(controller: time, label: 'Time'),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              initialValue: source,
              decoration: const InputDecoration(labelText: 'Source'),
              items: const [
                DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                DropdownMenuItem(value: 'Walk-in', child: Text('Walk-in')),
                DropdownMenuItem(value: 'Phone', child: Text('Phone')),
                DropdownMenuItem(value: 'App', child: Text('App')),
              ],
              onChanged: (value) =>
                  setDialogState(() => source = value ?? source),
            ),
          ],
        ),
      ),
    );

    customer.dispose();
    phone.dispose();
    date.dispose();
    time.dispose();
  }

  Future<void> _showCreateAdminDialog() async {
    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    final salonName = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _FormDialog(
        title: 'Create Admin User',
        actionLabel: 'Create User',
        formKey: formKey,
        onSubmit: () async {
          if (!(formKey.currentState?.validate() ?? false)) return;
          await groomeDashboardStore.createAdmin(
            name: name.text.trim(),
            email: email.text.trim(),
            password: password.text,
            salonName: salonName.text.trim(),
          );
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        },
        children: [
          _DialogField(controller: name, label: 'Admin name'),
          _DialogField(
            controller: email,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Required';
              if (!value.contains('@')) return 'Enter a valid email';
              if (groomeDashboardStore.emailExists(value.trim())) {
                return 'Email already exists';
              }
              return null;
            },
          ),
          _DialogField(
            controller: password,
            label: 'Password',
            obscureText: true,
            validator: _passwordValidator,
          ),
          _DialogField(controller: salonName, label: 'Salon name'),
        ],
      ),
    );

    name.dispose();
    email.dispose();
    password.dispose();
    salonName.dispose();
  }

  Future<void> _showPasswordDialog(DashboardUser user) async {
    final password = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _FormDialog(
        title: 'Edit Password',
        actionLabel: 'Save Password',
        formKey: formKey,
        onSubmit: () async {
          if (!(formKey.currentState?.validate() ?? false)) return;
          await groomeDashboardStore.updatePassword(user.id, password.text);
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        },
        children: [
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          _DialogField(
            controller: password,
            label: 'New password',
            obscureText: true,
            validator: _passwordValidator,
          ),
        ],
      ),
    );

    password.dispose();
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (value.length < 8) return 'Use at least 8 characters';
    return null;
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.title,
    required this.user,
    required this.child,
    required this.onSalonChanged,
    this.selectedSalon,
    this.selectedSalonId,
  });

  final String title;
  final DashboardUser user;
  final SalonProfile? selectedSalon;
  final String? selectedSalonId;
  final ValueChanged<String?> onSalonChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        _DashboardHeader(
          title: title,
          user: user,
          selectedSalon: selectedSalon,
          selectedSalonId: selectedSalonId,
          onSalonChanged: onSalonChanged,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              context.pagePadding,
              context.isMobile ? 18 : 28,
              context.pagePadding,
              42,
            ),
            child: child,
          ),
        ),
      ],
    ),
  );
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.title,
    required this.user,
    required this.onSalonChanged,
    this.selectedSalon,
    this.selectedSalonId,
  });

  final String title;
  final DashboardUser user;
  final SalonProfile? selectedSalon;
  final String? selectedSalonId;
  final ValueChanged<String?> onSalonChanged;

  @override
  Widget build(BuildContext context) {
    final salons = groomeDashboardStore.visibleSalons;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.pagePadding,
        vertical: context.isMobile ? 16 : 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, d MMMM y').format(DateTime.now()),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (!context.isMobile && salons.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.softCream,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSalonId,
                  icon: const Icon(Icons.expand_more_rounded),
                  items: [
                    for (final salon in salons)
                      DropdownMenuItem(
                        value: salon.id,
                        child: Text('${salon.name} - ${salon.locality}'),
                      ),
                  ],
                  onChanged: onSalonChanged,
                ),
              ),
            ),
            const SizedBox(width: 14),
          ],
          _NotificationBell(
            count: user.role == DashboardRole.superAdmin ? 5 : 3,
          ),
          const SizedBox(width: 12),
          _AccountChip(user: user, salon: selectedSalon),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.softCream,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.notifications_none_rounded),
      ),
      Positioned(
        top: -4,
        right: -3,
        child: Container(
          width: 21,
          height: 21,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFD92D20),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$count',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.white,
              fontSize: 11,
            ),
          ),
        ),
      ),
    ],
  );
}

class _AccountChip extends StatelessWidget {
  const _AccountChip({required this.user, this.salon});

  final DashboardUser user;
  final SalonProfile? salon;

  @override
  Widget build(BuildContext context) {
    final initials = user.role == DashboardRole.superAdmin
        ? 'SA'
        : (salon?.name ?? user.name)
              .split(' ')
              .where((part) => part.isNotEmpty)
              .take(2)
              .map((part) => part.characters.first)
              .join()
              .toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.softCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.gold.withValues(alpha: .18),
            child: Text(
              initials,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.goldDark,
                fontSize: 11,
              ),
            ),
          ),
          if (!context.isMobile) ...[
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.role == DashboardRole.superAdmin
                      ? 'Super Admin'
                      : salon?.name ?? user.primarySalonName,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.ink,
                    fontSize: 13,
                  ),
                ),
                Text(
                  user.role == DashboardRole.superAdmin
                      ? 'Groome control'
                      : salon?.locality ?? 'Partner',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 11, height: 1.2),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardSidebar extends StatelessWidget {
  const _DashboardSidebar({
    required this.user,
    required this.selected,
    required this.onSelected,
    required this.onLogout,
  });

  final DashboardUser user;
  final DashboardSection selected;
  final ValueChanged<DashboardSection> onSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => Container(
    width: 286,
    color: AppColors.ink,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrandLogo(light: true),
            const SizedBox(height: 6),
            Text(
              user.role == DashboardRole.superAdmin
                  ? 'Super Admin Dashboard'
                  : 'Partner Dashboard',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white.withValues(alpha: .62),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 28),
            if (user.role != DashboardRole.superAdmin)
              _BookingStatusCard(user: user),
            if (user.role != DashboardRole.superAdmin)
              const SizedBox(height: 26),
            Expanded(
              child: ListView(
                children: [
                  for (final section in DashboardSection.values)
                    if (section.visibleFor(user.role))
                      _DashboardNavButton(
                        section: section,
                        selected: section == selected,
                        onTap: () => onSelected(section),
                      ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF2A2F3A)),
            TextButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Logout'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.white.withValues(alpha: .72),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DashboardDrawer extends StatelessWidget {
  const _DashboardDrawer({
    required this.user,
    required this.selected,
    required this.onSelected,
    required this.onLogout,
  });

  final DashboardUser user;
  final DashboardSection selected;
  final ValueChanged<DashboardSection> onSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: AppColors.ink,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrandLogo(light: true),
            const SizedBox(height: 26),
            Expanded(
              child: ListView(
                children: [
                  for (final section in DashboardSection.values)
                    if (section.visibleFor(user.role))
                      _DashboardNavButton(
                        section: section,
                        selected: section == selected,
                        onTap: () => onSelected(section),
                      ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.white.withValues(alpha: .78),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BookingStatusCard extends StatelessWidget {
  const _BookingStatusCard({required this.user});

  final DashboardUser user;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.white.withValues(alpha: .08)),
    ),
    child: Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: user.subscriptionActive
                ? const Color(0xFF8CC63F)
                : const Color(0xFFD92D20),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.primarySalonName,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.white),
              ),
              Text(
                user.subscriptionActive
                    ? 'Accepting bookings'
                    : 'Subscription stopped',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withValues(alpha: .62),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.toggle_on_rounded, color: AppColors.gold, size: 36),
      ],
    ),
  );
}

class _DashboardNavButton extends StatelessWidget {
  const _DashboardNavButton({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final DashboardSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: selected
          ? AppColors.gold.withValues(alpha: .2)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Icon(
                section.icon,
                color: selected
                    ? AppColors.gold
                    : AppColors.white.withValues(alpha: .58),
                size: 21,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected
                        ? AppColors.gold
                        : AppColors.white.withValues(alpha: .68),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({
    required this.salon,
    required this.store,
    required this.onAddBooking,
    required this.onAddService,
    required this.onShowBookings,
  });

  final SalonProfile salon;
  final DashboardController store;
  final VoidCallback onAddBooking;
  final VoidCallback onAddService;
  final VoidCallback onShowBookings;

  @override
  Widget build(BuildContext context) {
    final bookings = store.bookingsFor(salon.id);
    final todaysBookings = bookings.where(
      (booking) => booking.date == store.today,
    );
    final revenue = todaysBookings.fold<int>(
      0,
      (total, booking) =>
          total + (store.serviceById(booking.serviceId)?.price ?? 0),
    );
    final activeBookings = bookings
        .where((booking) => booking.status != 'Cancelled')
        .length;
    final team = store.teamFor(salon.id);
    final services = store.servicesFor(salon.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricGrid(
          children: [
            _MetricCard(
              label: "Today's Revenue",
              value: money(revenue),
              detail: '${money(1900)} total target',
              icon: Icons.currency_rupee_rounded,
              accent: AppColors.goldDark,
            ),
            _MetricCard(
              label: 'Bookings Today',
              value: '${todaysBookings.length}',
              detail: '$activeBookings active',
              icon: Icons.event_available_outlined,
              accent: const Color(0xFF2E7D32),
            ),
            _MetricCard(
              label: 'Total Bookings',
              value: '${bookings.length}',
              detail: '+12% this week',
              icon: Icons.stacked_line_chart_rounded,
              accent: const Color(0xFF3B6EA8),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Occupancy', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 10),
              Text(
                '${team.isEmpty ? 0 : 72}%',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 42,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                salon.acceptingBookings ? 'Available slots' : 'Bookings paused',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: salon.acceptingBookings
                      ? AppColors.goldDark
                      : const Color(0xFFB42318),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _RatingPanel(
          bookings: bookings.length,
          revenue: services.fold(0, (sum, service) => sum + service.price),
        ),
        const SizedBox(height: 22),
        _RecentBookingsPanel(
          bookings: bookings.take(5).toList(),
          store: store,
          onShowBookings: onShowBookings,
        ),
        const SizedBox(height: 22),
        _QuickActions(
          actions: [
            _QuickAction(Icons.add_rounded, 'Add Appointment', onAddBooking),
            _QuickAction(Icons.block_rounded, 'Block Time', () {}),
            _QuickAction(Icons.groups_2_outlined, 'Manage Team', () {}),
            _QuickAction(
              Icons.content_cut_rounded,
              'Add Service',
              onAddService,
            ),
          ],
        ),
      ],
    );
  }
}

class _CalendarSection extends StatelessWidget {
  const _CalendarSection({
    required this.salon,
    required this.store,
    required this.weekMode,
    required this.teamFilter,
    required this.onModeChanged,
    required this.onTeamFilterChanged,
    required this.onAddBooking,
  });

  final SalonProfile salon;
  final DashboardController store;
  final bool weekMode;
  final String teamFilter;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<String> onTeamFilterChanged;
  final VoidCallback onAddBooking;

  @override
  Widget build(BuildContext context) {
    final team = store.teamFor(salon.id);
    final bookings = store.bookingsFor(salon.id).where((booking) {
      if (teamFilter == 'all') return true;
      return booking.teamMemberId == teamFilter;
    }).toList();
    const slots = ['10:00 AM', '11:30 AM', '02:00 PM', '03:30 PM', '04:30 PM'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Toolbar(
          leading: [
            _SegmentedButton(
              label: 'Day',
              selected: !weekMode,
              onPressed: () => onModeChanged(false),
            ),
            _SegmentedButton(
              label: 'Week',
              selected: weekMode,
              onPressed: () => onModeChanged(true),
            ),
          ],
          trailing: _DashboardButton(
            label: 'Add Booking',
            icon: Icons.add_rounded,
            onPressed: onAddBooking,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterChip(
              label: 'All stylists',
              selected: teamFilter == 'all',
              onTap: () => onTeamFilterChanged('all'),
            ),
            for (final member in team)
              _FilterChip(
                label: member.name,
                selected: teamFilter == member.id,
                onTap: () => onTeamFilterChanged(member.id),
              ),
          ],
        ),
        const SizedBox(height: 18),
        _Panel(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              for (final slot in slots)
                _CalendarSlot(
                  slot: slot,
                  bookings: bookings
                      .where((booking) => booking.time == slot)
                      .toList(),
                  store: store,
                  onEmptyTap: onAddBooking,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingsSection extends StatelessWidget {
  const _BookingsSection({
    required this.salon,
    required this.store,
    required this.filter,
    required this.onFilterChanged,
    required this.onAddBooking,
  });

  final SalonProfile salon;
  final DashboardController store;
  final BookingFilter filter;
  final ValueChanged<BookingFilter> onFilterChanged;
  final VoidCallback onAddBooking;

  @override
  Widget build(BuildContext context) {
    var bookings = store.bookingsFor(salon.id);
    if (filter == BookingFilter.confirmed) {
      bookings = bookings
          .where((booking) => booking.status == 'Confirmed')
          .toList();
    } else if (filter == BookingFilter.cancelled) {
      bookings = bookings
          .where((booking) => booking.status == 'Cancelled')
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Toolbar(
          leading: [
            _SegmentedButton(
              label: 'All',
              selected: filter == BookingFilter.all,
              onPressed: () => onFilterChanged(BookingFilter.all),
            ),
            _SegmentedButton(
              label: 'Confirmed',
              selected: filter == BookingFilter.confirmed,
              onPressed: () => onFilterChanged(BookingFilter.confirmed),
            ),
            _SegmentedButton(
              label: 'Cancelled',
              selected: filter == BookingFilter.cancelled,
              onPressed: () => onFilterChanged(BookingFilter.cancelled),
            ),
          ],
          trailing: _DashboardButton(
            label: 'New Appointment',
            icon: Icons.add_rounded,
            onPressed: onAddBooking,
          ),
        ),
        const SizedBox(height: 18),
        _Panel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final booking in bookings)
                _BookingRow(booking: booking, store: store),
              if (bookings.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(28),
                  child: _EmptyInline('No bookings for this filter.'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClientsSection extends StatelessWidget {
  const _ClientsSection({
    required this.salon,
    required this.store,
    required this.query,
    required this.onQueryChanged,
  });

  final SalonProfile salon;
  final DashboardController store;
  final String query;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final clients = store.clientsFor(salon.id).where((client) {
      final needle = query.toLowerCase();
      return client.name.toLowerCase().contains(needle) ||
          client.phone.toLowerCase().contains(needle);
    }).toList();

    return Column(
      children: [
        TextField(
          onChanged: onQueryChanged,
          decoration: const InputDecoration(
            hintText: 'Search clients by name or phone',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final client in clients)
                SizedBox(
                  width: constraints.maxWidth < 760
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 16) / 2,
                  child: _ClientCard(client: client),
                ),
              if (clients.isEmpty)
                const _EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No clients found',
                  body: 'Try searching by another name or phone number.',
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SalonsSection extends StatelessWidget {
  const _SalonsSection({
    required this.user,
    required this.store,
    required this.onAddSalon,
    required this.onEditSalon,
  });

  final DashboardUser user;
  final DashboardController store;
  final VoidCallback onAddSalon;
  final ValueChanged<SalonProfile> onEditSalon;

  @override
  Widget build(BuildContext context) {
    final salons = store.visibleSalons;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Toolbar(
          leading: [
            Text(
              '${salons.length} salon${salons.length == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          trailing: _DashboardButton(
            label: 'Add Salon',
            icon: Icons.add_business_outlined,
            onPressed: onAddSalon,
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final salon in salons)
                SizedBox(
                  width: constraints.maxWidth < 820
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 16) / 2,
                  child: _SalonCard(
                    salon: salon,
                    teamCount: store.teamFor(salon.id).length,
                    serviceCount: store.servicesFor(salon.id).length,
                    onEdit: () => onEditSalon(salon),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamSection extends StatelessWidget {
  const _TeamSection({
    required this.salon,
    required this.store,
    required this.onAddMember,
  });

  final SalonProfile salon;
  final DashboardController store;
  final VoidCallback onAddMember;

  @override
  Widget build(BuildContext context) {
    final members = store.teamFor(salon.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Toolbar(
          leading: [
            Text(
              '${members.length} team members',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          trailing: _DashboardButton(
            label: 'Add Member',
            icon: Icons.person_add_alt_1_outlined,
            onPressed: onAddMember,
          ),
        ),
        const SizedBox(height: 18),
        for (final member in members) ...[
          _TeamMemberCard(member: member, store: store),
          const SizedBox(height: 14),
        ],
        if (members.isEmpty)
          _EmptyState(
            icon: Icons.groups_2_outlined,
            title: 'No team members',
            body: 'Add stylists so services can generate available slots.',
            actionLabel: 'Add Member',
            onAction: onAddMember,
          ),
      ],
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({
    required this.salon,
    required this.store,
    required this.onAddService,
  });

  final SalonProfile salon;
  final DashboardController store;
  final VoidCallback onAddService;

  @override
  Widget build(BuildContext context) {
    final services = store.servicesFor(salon.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Toolbar(
          leading: [
            Text(
              '${services.length} services',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          trailing: _DashboardButton(
            label: 'Add Service',
            icon: Icons.add_rounded,
            onPressed: onAddService,
          ),
        ),
        const SizedBox(height: 18),
        _Panel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final service in services)
                _ServiceRow(service: service, store: store),
              if (services.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: _EmptyState(
                    icon: Icons.content_cut_rounded,
                    title: 'No services',
                    body:
                        'Create services with duration, price, and assigned team.',
                    actionLabel: 'Add Service',
                    onAction: onAddService,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalyticsSection extends StatelessWidget {
  const _AnalyticsSection({required this.salon, required this.store});

  final SalonProfile salon;
  final DashboardController store;

  @override
  Widget build(BuildContext context) {
    final bookings = store.bookingsFor(salon.id);
    final revenue = bookings.fold<int>(
      0,
      (sum, booking) => booking.status == 'Cancelled'
          ? sum
          : sum + (store.serviceById(booking.serviceId)?.price ?? 0),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricGrid(
          children: [
            _MetricCard(
              label: 'This Week Revenue',
              value: money(78200),
              detail: '+8% vs last week',
              icon: Icons.trending_up_rounded,
              accent: const Color(0xFF2E7D32),
            ),
            _MetricCard(
              label: 'Bookings This Week',
              value: '41',
              detail: '6 more',
              icon: Icons.event_available_outlined,
              accent: const Color(0xFF3B6EA8),
            ),
            _MetricCard(
              label: 'Avg Ticket',
              value: money(bookings.isEmpty ? 0 : revenue ~/ bookings.length),
              detail: 'Per booking',
              icon: Icons.receipt_long_outlined,
              accent: AppColors.goldDark,
            ),
          ],
        ),
        const SizedBox(height: 22),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Repeat Rate', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 10),
              Text(
                '68%',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.ink,
                  fontSize: 46,
                ),
              ),
              Text(
                'Returning customers',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF805AD5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _WeeklyRevenueChart(),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.salon,
    required this.store,
    required this.onEditSalon,
  });

  final SalonProfile salon;
  final DashboardController store;
  final VoidCallback onEditSalon;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Salon Profile',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                _DashboardButton(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  onPressed: onEditSalon,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SettingsRow(label: 'Salon Name', value: salon.name),
            _SettingsRow(label: 'Phone', value: salon.phone),
            _SettingsRow(label: 'Email', value: salon.email),
            _SettingsRow(label: 'Address', value: salon.address),
            _SettingsRow(
              label: 'Opening Hours',
              value: '${salon.openingTime} - ${salon.closingTime}',
            ),
            const SizedBox(height: 18),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: salon.acceptingBookings,
              activeThumbColor: AppColors.gold,
              title: const Text('Accept online bookings'),
              subtitle: const Text(
                'Inactive salons disappear from customer booking.',
              ),
              onChanged: (_) => store.toggleSalonBookings(salon.id),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: true,
              activeThumbColor: AppColors.gold,
              title: const Text('WhatsApp notifications'),
              subtitle: const Text(
                'New bookings, cancellations, and reminders.',
              ),
              onChanged: (_) {},
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: true,
              activeThumbColor: AppColors.gold,
              title: const Text('Auto confirm bookings'),
              subtitle: const Text('Switch off for manual confirmation mode.'),
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    ],
  );
}

class _AdminsSection extends StatelessWidget {
  const _AdminsSection({
    required this.store,
    required this.onCreateAdmin,
    required this.onEditPassword,
  });

  final DashboardController store;
  final VoidCallback onCreateAdmin;
  final ValueChanged<DashboardUser> onEditPassword;

  @override
  Widget build(BuildContext context) {
    final admins = store.users;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Toolbar(
          leading: [
            Text(
              '${admins.length} users',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          trailing: _DashboardButton(
            label: 'Create User',
            icon: Icons.person_add_alt_1_rounded,
            onPressed: onCreateAdmin,
          ),
        ),
        const SizedBox(height: 18),
        _Panel(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: Theme.of(context).textTheme.labelLarge,
              dataTextStyle: Theme.of(context).textTheme.bodyMedium,
              columns: const [
                DataColumn(label: Text('User')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Salon')),
                DataColumn(label: Text('Subscription')),
                DataColumn(label: Text('Actions')),
              ],
              rows: [
                for (final user in admins)
                  DataRow(
                    cells: [
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(user.email),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          user.role == DashboardRole.superAdmin
                              ? 'Super Admin'
                              : 'Admin',
                        ),
                      ),
                      DataCell(Text(user.primarySalonName)),
                      DataCell(
                        _StatusPill(
                          label: user.role == DashboardRole.superAdmin
                              ? 'Owner'
                              : user.subscriptionActive
                              ? 'Active'
                              : 'Stopped',
                          positive: user.subscriptionActive,
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => onEditPassword(user),
                              child: const Text('Password'),
                            ),
                            if (user.role != DashboardRole.superAdmin)
                              TextButton(
                                onPressed: () =>
                                    store.toggleSubscription(user.id),
                                child: Text(
                                  user.subscriptionActive ? 'Stop' : 'Resume',
                                ),
                              ),
                            if (user.role != DashboardRole.superAdmin)
                              TextButton(
                                onPressed: () => store.deleteUser(user.id),
                                child: const Text('Delete'),
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
        const SizedBox(height: 14),
        Text(
          'Stopped users cannot login and will see: "Your subscription is stopped. Please contact with Super Admin."',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth < 760 ? 1 : children.length;
      final gap = 16.0;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
            Icon(icon, color: accent),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          value,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppColors.ink,
            fontSize: 38,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          detail,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: accent),
        ),
      ],
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(26),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.line),
      boxShadow: [
        BoxShadow(
          color: AppColors.ink.withValues(alpha: .035),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: child,
  );
}

class _RatingPanel extends StatelessWidget {
  const _RatingPanel({required this.bookings, required this.revenue});

  final int bookings;
  final int revenue;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(22),
    ),
    child: context.isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _ratingChildren(context),
          )
        : Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _ratingChildren(context),
                ),
              ),
              _DarkStat(label: 'Total Reviews', value: '$bookings'),
              const SizedBox(width: 28),
              _DarkStat(label: 'Total Revenue', value: money(revenue)),
            ],
          ),
  );

  List<Widget> _ratingChildren(BuildContext context) => [
    Text(
      '4.8',
      style: Theme.of(
        context,
      ).textTheme.displayMedium?.copyWith(color: AppColors.gold, fontSize: 56),
    ),
    const SizedBox(height: 8),
    const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.gold),
        Icon(Icons.star_rounded, color: AppColors.gold),
        Icon(Icons.star_rounded, color: AppColors.gold),
        Icon(Icons.star_rounded, color: AppColors.gold),
        Icon(Icons.star_half_rounded, color: AppColors.gold),
      ],
    ),
    const SizedBox(height: 12),
    Text(
      'Average rating',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.white.withValues(alpha: .66),
      ),
    ),
  ];
}

class _DarkStat extends StatelessWidget {
  const _DarkStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(left: 28),
    decoration: BoxDecoration(
      border: Border(
        left: BorderSide(color: AppColors.white.withValues(alpha: .14)),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.white,
            fontSize: 31,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.white.withValues(alpha: .58),
          ),
        ),
      ],
    ),
  );
}

class _RecentBookingsPanel extends StatelessWidget {
  const _RecentBookingsPanel({
    required this.bookings,
    required this.store,
    required this.onShowBookings,
  });

  final List<BookingItem> bookings;
  final DashboardController store;
  final VoidCallback onShowBookings;

  @override
  Widget build(BuildContext context) => _Panel(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 22, 20, 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Bookings',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              TextButton.icon(
                onPressed: onShowBookings,
                label: const Text('View all'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 17),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.line),
        for (final booking in bookings)
          _BookingRow(booking: booking, store: store, compact: true),
      ],
    ),
  );
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({
    required this.booking,
    required this.store,
    this.compact = false,
  });

  final BookingItem booking;
  final DashboardController store;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final service = store.serviceById(booking.serviceId);
    final member = store.teamById(booking.teamMemberId);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 26 : 28,
        vertical: compact ? 16 : 22,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.line.withValues(alpha: .75)),
        ),
      ),
      child: Row(
        children: [
          _InitialBox(text: service?.name ?? booking.customerName),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      service?.name ?? 'Service',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    _StatusPill(
                      label: booking.status,
                      positive: booking.status != 'Cancelled',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking.customerName} - ${member?.name ?? 'Any stylist'} - ${booking.date} - ${booking.time}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (!compact)
                  Text(
                    'Ref: ${booking.id} - ${booking.source}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
              ],
            ),
          ),
          if (!context.isMobile) ...[
            Text(
              money(service?.price ?? 0),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(width: 18),
          ],
          if (!compact && booking.status != 'Cancelled')
            OutlinedButton.icon(
              onPressed: () => store.cancelBooking(booking.id),
              icon: const Icon(Icons.close_rounded, size: 17),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB42318),
                side: const BorderSide(color: Color(0xFFB42318)),
              ),
            ),
        ],
      ),
    );
  }
}

class _CalendarSlot extends StatelessWidget {
  const _CalendarSlot({
    required this.slot,
    required this.bookings,
    required this.store,
    required this.onEmptyTap,
  });

  final String slot;
  final List<BookingItem> bookings;
  final DashboardController store;
  final VoidCallback onEmptyTap;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: AppColors.line.withValues(alpha: .78)),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(slot, style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(
          child: bookings.isEmpty
              ? InkWell(
                  onTap: onEmptyTap,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.softCream,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Text(
                      'Empty slot',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final booking in bookings)
                      Container(
                        width: context.isMobile ? double.infinity : 260,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: .13),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: .4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.customerName,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              store.serviceById(booking.serviceId)?.name ??
                                  'Service',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    ),
  );
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.client});

  final ClientProfile client;

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _InitialBox(text: client.name),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    client.phone,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 22,
          runSpacing: 12,
          children: [
            _MiniStat(label: 'Visits', value: '${client.totalVisits}'),
            _MiniStat(label: 'Spend', value: money(client.totalSpend)),
            _MiniStat(label: 'Last visit', value: client.lastVisit),
            _MiniStat(label: 'No shows', value: '${client.noShowCount}'),
          ],
        ),
        const SizedBox(height: 16),
        Text(client.notes, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}

class _SalonCard extends StatelessWidget {
  const _SalonCard({
    required this.salon,
    required this.teamCount,
    required this.serviceCount,
    required this.onEdit,
  });

  final SalonProfile salon;
  final int teamCount;
  final int serviceCount;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _InitialBox(text: salon.name),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salon.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    salon.locality,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            _StatusPill(
              label: salon.acceptingBookings ? 'Live' : 'Paused',
              positive: salon.acceptingBookings,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(salon.address, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            _MiniStat(label: 'Team', value: '$teamCount'),
            _MiniStat(label: 'Services', value: '$serviceCount'),
            _MiniStat(
              label: 'Hours',
              value: '${salon.openingTime} - ${salon.closingTime}',
            ),
          ],
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit Profile'),
        ),
      ],
    ),
  );
}

class _TeamMemberCard extends StatelessWidget {
  const _TeamMemberCard({required this.member, required this.store});

  final TeamMember member;
  final DashboardController store;

  @override
  Widget build(BuildContext context) => _Panel(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              _InitialBox(text: member.name),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${member.role} - ${member.experience}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Switch(
                value: member.active,
                activeThumbColor: AppColors.gold,
                onChanged: (_) => store.toggleTeamMember(member.id),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          color: AppColors.softCream,
          child: Wrap(
            spacing: 26,
            runSpacing: 12,
            children: [
              _MiniStat(
                label: 'Rating',
                value: member.rating.toStringAsFixed(1),
              ),
              _MiniStat(
                label: 'Bookings',
                value: '${member.bookingsThisMonth}',
              ),
              _MiniStat(label: 'Revenue', value: money(member.revenue)),
              _MiniStat(label: 'Schedule', value: member.workingDays),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final service in member.services)
                      _SoftTag(label: service),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => store.removeTeamMember(member.id),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Remove'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFB42318),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.service, required this.store});

  final ServiceItem service;
  final DashboardController store;

  @override
  Widget build(BuildContext context) {
    final assigned = service.teamMemberIds
        .map(store.teamById)
        .whereType<TeamMember>()
        .map((member) => member.name)
        .join(', ');
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.line.withValues(alpha: .78)),
        ),
      ),
      child: Row(
        children: [
          _InitialBox(text: service.name),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${service.category} - ${service.durationMinutes} min - ${assigned.isEmpty ? 'No team assigned' : assigned}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(
            money(service.price),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(width: 14),
          IconButton(
            tooltip: 'Delete service',
            onPressed: () => store.removeService(service.id),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _WeeklyRevenueChart extends StatelessWidget {
  const _WeeklyRevenueChart();

  @override
  Widget build(BuildContext context) {
    const values = [8, 10, 10, 13, 14, 16, 7];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Revenue',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            money(78000),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppColors.gold,
              fontSize: 46,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 230,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < values.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${values[i]}k',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            height: values[i] * 9,
                            decoration: BoxDecoration(
                              color: i == 5
                                  ? AppColors.gold
                                  : AppColors.gold.withValues(alpha: .25),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            days[i],
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.actions});

  final List<_QuickAction> actions;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        for (final action in actions)
          SizedBox(
            width: constraints.maxWidth < 760
                ? constraints.maxWidth
                : (constraints.maxWidth - 48) / 4,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: action.onTap,
              child: _Panel(
                child: Column(
                  children: [
                    Icon(action.icon, color: AppColors.ink, size: 30),
                    const SizedBox(height: 14),
                    Text(
                      action.label,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _QuickAction {
  const _QuickAction(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.leading, required this.trailing});

  final List<Widget> leading;
  final Widget trailing;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    runSpacing: 12,
    spacing: 12,
    children: [
      Wrap(spacing: 8, runSpacing: 8, children: leading),
      trailing,
    ],
  );
}

class _SegmentedButton extends StatelessWidget {
  const _SegmentedButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      backgroundColor: selected ? AppColors.gold : AppColors.white,
      foregroundColor: selected ? AppColors.ink : AppColors.muted,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    child: Text(label),
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(999),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? AppColors.ink : AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: selected ? AppColors.ink : AppColors.line),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: selected ? AppColors.white : AppColors.ink,
        ),
      ),
    ),
  );
}

class _DashboardButton extends StatelessWidget {
  const _DashboardButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 18),
    label: Text(label),
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.gold,
      foregroundColor: AppColors.ink,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.positive});

  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: positive
          ? AppColors.gold.withValues(alpha: .16)
          : const Color(0xFFFFE8E6),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: positive ? AppColors.goldDark : const Color(0xFFB42318),
        fontSize: 12,
      ),
    ),
  );
}

class _InitialBox extends StatelessWidget {
  const _InitialBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final initial = text.trim().isEmpty
        ? 'G'
        : text.trim().characters.first.toUpperCase();
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        initial,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: AppColors.goldDark),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AppColors.ink, fontSize: 16),
      ),
      Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
      ),
    ],
  );
}

class _SoftTag extends StatelessWidget {
  const _SoftTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.gold.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.goldDark,
        fontSize: 12,
        height: 1,
      ),
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 7),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: AppColors.softCream,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.ink),
          ),
        ),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 40, color: AppColors.goldDark),
        const SizedBox(height: 14),
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          body,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 20),
          _DashboardButton(
            label: actionLabel!,
            icon: Icons.add_rounded,
            onPressed: onAction!,
          ),
        ],
      ],
    ),
  );
}

class _EmptyInline extends StatelessWidget {
  const _EmptyInline(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
  );
}

enum _NoticeTone { danger }

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.message, required this.tone});

  final String message;
  final _NoticeTone tone;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1F0),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFFFC9C5)),
    ),
    child: Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: const Color(0xFFB42318),
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _FormDialog extends StatefulWidget {
  const _FormDialog({
    required this.title,
    required this.actionLabel,
    required this.formKey,
    required this.children,
    required this.onSubmit,
  });

  final String title;
  final String actionLabel;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final Future<void> Function() onSubmit;

  @override
  State<_FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<_FormDialog> {
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await widget.onSubmit();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _actionErrorMessage(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _actionErrorMessage(Object error) {
    if (error is FirebaseFunctionsException) {
      final message = error.message;
      if (message != null && message.trim().isNotEmpty) return message;

      return switch (error.code) {
        'already-exists' => 'An account already exists for this email.',
        'permission-denied' => 'Only Super Admin can perform this action.',
        'unauthenticated' => 'Please log in again to continue.',
        _ => 'Could not complete this action. Please try again.',
      };
    }

    return 'Could not complete this action. Please try again.';
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppColors.white,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: Text(widget.title),
    content: SizedBox(
      width: 520,
      child: SingleChildScrollView(
        child: Form(
          key: widget.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final child in widget.children) ...[
                child,
                const SizedBox(height: 14),
              ],
              if (_error != null)
                _InlineNotice(message: _error!, tone: _NoticeTone.danger),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _submitting ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: _submitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.white,
        ),
        child: _submitting
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(widget.actionLabel),
      ),
    ],
  );
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    obscureText: obscureText,
    decoration: InputDecoration(labelText: label),
    validator:
        validator ??
        (value) {
          if (value == null || value.trim().isEmpty) return 'Required';
          return null;
        },
  );
}

String money(num value) {
  final formatter = NumberFormat('#,##0');
  return 'Rs ${formatter.format(value)}';
}
