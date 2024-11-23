import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final VoidCallback onPressed;
  final bool hasFullWidth; // Flag to control the width

  const ActionButton({
    required this.label,
    required this.backgroundColor,
    required this.onPressed,
    this.hasFullWidth = true, // Default is true for full width
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Conditionally wrap the ElevatedButton with SizedBox for full width
    return hasFullWidth
        ? SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    )
        : ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
