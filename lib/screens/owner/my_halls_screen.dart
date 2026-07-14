import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/screens/reviews/owner_reviews_screen.dart';
import 'package:marriage_hall_app/widgets/owner/owner_hall_card.dart';

class MyHallsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> halls;
  final Future<void> Function() onAddHall;
  final Future<void> Function(int index) onEditHall;
  final ValueChanged<int> onDeleteHall;

  const MyHallsScreen({
    super.key,
    required this.halls,
    required this.onAddHall,
    required this.onEditHall,
    required this.onDeleteHall,
  });

  void openReviews(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OwnerReviewsScreen(
          initialHallFilter: halls[index]['hallName'],
        ),
      ),
    );
  }

  Future<void> confirmDelete(BuildContext context, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Hall"),
        content: Text(
          "Are you sure you want to delete \"${halls[index]['hallName']}\"?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDeleteHall(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("My Halls"), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAddHall,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          "Add Hall",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: halls.isEmpty
          ? const Center(child: Text("No halls added yet"))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.md,
                AppSizes.md,
                96,
              ),
              itemCount: halls.length,
              itemBuilder: (context, index) {
                return OwnerHallCard(
                  hall: halls[index],
                  onTap: () => onEditHall(index),
                  onEdit: () => onEditHall(index),
                  onDelete: () => confirmDelete(context, index),
                  onViewReviews: () => openReviews(context, index),
                );
              },
            ),
    );
  }
}
