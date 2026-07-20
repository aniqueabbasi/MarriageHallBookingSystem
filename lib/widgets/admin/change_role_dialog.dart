import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/models/admin/admin_user.dart';
import 'package:marriage_hall_app/widgets/admin/role_badge.dart';

const _assignableRoles = ['Admin', 'HallOwner', 'Customer'];

/// Role picker only — pops with the selected backend role string when it
/// differs from the current one, or null on cancel. Confirmation and the
/// actual PATCH are the caller's job, keeping API calls out of widgets.
class ChangeRoleDialog extends StatefulWidget {
  final AdminUser user;

  const ChangeRoleDialog({super.key, required this.user});

  @override
  State<ChangeRoleDialog> createState() => _ChangeRoleDialogState();
}

class _ChangeRoleDialogState extends State<ChangeRoleDialog> {
  late String selectedRole = widget.user.role;

  @override
  Widget build(BuildContext context) {
    final unchanged = selectedRole == widget.user.role;

    return AlertDialog(
      title: const Text('Change Role'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.user.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Current role: ${roleLabel(widget.user.role)}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          for (final role in _assignableRoles)
            RadioListTile<String>(
              value: role,
              // ignore: deprecated_member_use
              groupValue: selectedRole,
              // ignore: deprecated_member_use
              onChanged: (value) =>
                  setState(() => selectedRole = value ?? selectedRole),
              title: Text(roleLabel(role)),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: unchanged
              ? null
              : () => Navigator.pop(context, selectedRole),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
