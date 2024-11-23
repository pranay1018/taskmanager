import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../../utils/color_constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSignupTap;
  final VoidCallback? onLoginTap;
  final VoidCallback? onLogOut;
  final bool isHomePage;

  const CustomAppBar({
    this.onSignupTap,
    this.onLoginTap,
    this.onLogOut,
    this.isHomePage = false, // Default value for isHomePage
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorConstants.primary,
      leading: const Icon(
        Icons.event_note_sharp,
        color: ColorConstants.background,
      ),
      actions: [
        isHomePage
            ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: _AppBarButton(
            label: 'Logout',
            style: AppTheme.caption,
            backgroundColor: Colors.white,
            onPressed: onLogOut ?? () {}, // Provide a default empty function if onLogOut is null
          ),
        )
            : Row(
          children: [
            if (onLoginTap != null)
              _AppBarButton(
                label: 'Login',
                style: AppTheme.caption,
                backgroundColor: Colors.white,
                onPressed: onLoginTap!,
              ),
            if (onSignupTap != null)
              TextButton(
                onPressed: onSignupTap!,
                child: Text(
                  'Signup',
                  style: AppTheme.captionWhite,
                ),
              ),
          ],
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarButton extends StatelessWidget {
  final String label;
  final TextStyle style;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const _AppBarButton({
    required this.label,
    required this.style,
    required this.backgroundColor,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
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
        style: style,
      ),
    );
  }
}
