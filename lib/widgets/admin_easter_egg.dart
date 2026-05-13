import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AdminEasterEgg extends StatelessWidget {
  const AdminEasterEgg({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 35,
      height: 35,
      child: Lottie.network(
        'https://assets9.lottiefiles.com/packages/lf20_xh83pj1c.json',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox(),
      ),
    );
  }
}