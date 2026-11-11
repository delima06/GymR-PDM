import 'package:flutter/material.dart';

class GymrLogoTitle extends StatelessWidget {
  final String title;
  final double logoHeight;

  const GymrLogoTitle({
    super.key,
    required this.title,
    this.logoHeight = 28.0,
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
                fontSize: 20,
                letterSpacing: 1.2,
              ),
            );
          },
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }
}

