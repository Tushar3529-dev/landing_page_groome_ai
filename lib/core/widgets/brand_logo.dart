import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landing_groom_page/core/constants/app_constants.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.light = false});

  final bool light;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Groome home',
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
      /*   Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            'G',
            style: GoogleFonts.cormorantGaramond(
              color: AppColors.ink,
              fontSize: 23,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 10), */
        Text(
          'groome',
          style: GoogleFonts.manrope(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: light ? AppColors.white : AppColors.ink,
          ),
        ),
      ],
    ),
  );
}
