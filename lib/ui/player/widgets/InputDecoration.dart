// Define customInputDecoration here to pass it down
import 'package:flutter/material.dart';

InputDecoration buildCustomInputDecoration(TextTheme textTheme) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.blue),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.blue, width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red[700]!, width: 2),
    ),
    hoverColor: Colors.transparent, // Disable hover effect
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    hintStyle: textTheme.bodyLarge?.copyWith(color: Colors.blue[500]),
  );
}