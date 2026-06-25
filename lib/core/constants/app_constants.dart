import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF0D0D0D);
  static const gold = Color(0xFFD4AF37);
  static const goldDark = Color(0xFFA8861D);
  static const cream = Color(0xFFF7F3EB);
  static const softCream = Color(0xFFFBF9F5);
  static const white = Color(0xFFFFFFFF);
  static const muted = Color(0xFF6E6A62);
  static const line = Color(0xFFE8E1D5);
}

abstract final class AppAssets {
  static const salonInterior = 'assets/images/salon-interior.png';
  static const salonConsultation = 'assets/images/salon-consultation.png';
  static const salonOwner = 'assets/images/salon-owner.png';

  static const salonImages = [salonInterior, salonConsultation, salonOwner];
}

abstract final class AppRoutes {
  static const home = '/';
  static const features = '/features';
  static const contact = '/contact';
  static const about = '/about';
  static const privacyPolicy = '/privacy-policy';
  static const termsConditions = '/terms-and-conditions';
}

abstract final class AppBreakpoints {
  static const mobile = 680.0;
  static const tablet = 1024.0;
  static const contentMax = 1240.0;
}
