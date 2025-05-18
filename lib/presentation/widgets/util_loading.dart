import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class UtilLoading extends StatelessWidget {
  const UtilLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.6), // Nền đen mờ
      child: Center(
        child: Lottie.asset(
          'lib/assets/lottie/loading.json',
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.contain,
          repeat: true,
        ),
      ),
    );
  }
}
