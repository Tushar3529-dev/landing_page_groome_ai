import 'package:flutter/material.dart';
import 'package:landing_groom_page/core/constants/app_constants.dart';

class AppButton extends StatefulWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.outlined = false,
    this.light = false,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool light;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final foreground = widget.outlined
        ? (widget.light ? AppColors.white : AppColors.ink)
        : AppColors.white;
    final background = widget.outlined
        ? Colors.transparent
        : (_hovered ? AppColors.goldDark : AppColors.ink);

    final child = MouseRegion(
      cursor: widget.onPressed == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: widget.outlined
                ? (widget.light ? AppColors.white : AppColors.ink)
                : background,
          ),
          boxShadow: _hovered && !widget.outlined
              ? [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: .18),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.loading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: widget.expand
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                children: [
                  if (widget.loading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foreground,
                      ),
                    )
                  else ...[
                    Text(
                      widget.label,
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: foreground),
                    ),
                    if (widget.icon != null) ...[
                      const SizedBox(width: 9),
                      Icon(widget.icon, size: 18, color: foreground),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return widget.expand
        ? SizedBox(width: double.infinity, child: child)
        : child;
  }
}
