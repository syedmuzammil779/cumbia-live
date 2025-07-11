import 'package:flutter/material.dart';

void showToast(BuildContext context, String message) {
  if (!context.mounted) return;
  Future.delayed(Duration.zero, () {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  });
}