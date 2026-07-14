import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';

final obscureTextProvider = StateProvider.autoDispose.family<bool, String>(
  (ref, fieldId) => true,
);

class AuthTextField extends ConsumerWidget {
  final String fieldId;
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.fieldId,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final obscureText = ref.watch(obscureTextProvider(fieldId));

    return TextFormField(
      controller: controller,
      obscureText: isPassword && obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: () {
                  ref.read(obscureTextProvider(fieldId).notifier).state =
                      !obscureText;
                },
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
      ),
    );
  }
}
