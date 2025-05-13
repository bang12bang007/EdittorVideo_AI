import 'package:flutter/material.dart';

import '../../assets/colors.dart';

class UtilButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? height;
  final double? borderRadius;
  const UtilButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 50, // Giá trị mặc định
    this.borderRadius = 10, // Giá trị mặc định
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(Size.fromHeight(height ?? 50)),
        backgroundColor: MaterialStateProperty.all(UtilColors.primaryColor),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
          ),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
