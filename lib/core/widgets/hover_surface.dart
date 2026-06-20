import 'package:flutter/material.dart';
import 'package:landing_groom_page/core/constants/app_constants.dart';

class HoverSurface extends StatefulWidget {
  const HoverSurface({required this.child, super.key, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  State<HoverSurface> createState() => _HoverSurfaceState();
}

class _HoverSurfaceState extends State<HoverSurface> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, _hovered ? -8 : 0, 0),
      padding: widget.padding ?? const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _hovered
              ? AppColors.gold.withValues(alpha: .65)
              : AppColors.line,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: _hovered ? .1 : .035),
            blurRadius: _hovered ? 34 : 16,
            offset: Offset(0, _hovered ? 16 : 8),
          ),
        ],
      ),
      child: widget.child,
    ),
  );
}
