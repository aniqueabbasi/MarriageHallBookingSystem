import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../data/notification_dummy_data.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Notifications"), centerTitle: true),
      body: dummyNotifications.isEmpty
          ? const Center(child: Text("No notifications yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.md),
              itemCount: dummyNotifications.length,
              itemBuilder: (context, index) {
                return NotificationTile(notification: dummyNotifications[index]);
              },
            ),
    );
  }
}
