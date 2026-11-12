import 'package:flutter/material.dart';

class GymrLogoTitle extends StatelessWidget {
  final String title;
  final double logoHeight;

  const GymrLogoTitle({
    super.key,
    required this.title,
    this.logoHeight = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/logotipo_gymr.png',
          height: logoHeight,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Text(
              'GymR',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 1.1,
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        Container(
          height: 16,
          width: 1,
          color: Colors.white.withValues(alpha: 0.15),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: -0.3,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

