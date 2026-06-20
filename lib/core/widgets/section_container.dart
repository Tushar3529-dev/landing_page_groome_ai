import 'package:flutter/widgets.dart';
import 'package:landing_groom_page/core/constants/app_constants.dart';
import 'package:landing_groom_page/core/utils/responsive.dart';

class SectionContainer extends StatelessWidget {
  const SectionContainer({
    required this.child,
    super.key,
    this.padding,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: color ?? const Color(0x00000000),
    child: Padding(
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: context.pagePadding,
            vertical: context.isMobile ? 72 : 112,
          ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.contentMax,
          ),
          child: child,
        ),
      ),
    ),
  );
}
