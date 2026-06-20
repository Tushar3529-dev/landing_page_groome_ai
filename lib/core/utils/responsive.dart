import 'package:flutter/widgets.dart';
import 'package:landing_groom_page/core/constants/app_constants.dart';

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  bool get isMobile => screenWidth < AppBreakpoints.mobile;
  bool get isTablet =>
      screenWidth >= AppBreakpoints.mobile &&
      screenWidth < AppBreakpoints.tablet;

  double get pagePadding => isMobile ? 20 : (isTablet ? 36 : 48);
}
