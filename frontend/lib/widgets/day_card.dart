import 'package:flutter/material.dart';
import 'package:frontend/theme/colors.dart';
import 'package:frontend/widgets/pastel_card.dart';

class _DayPlanCard extends StatelessWidget {
  final Map<String, dynamic> dayPlan;

  const _DayPlanCard(this.dayPlan);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PastelCard(
        color: AppColors.surface,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 4),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          title: Text(
            "Day ${dayPlan["day"]}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              dayPlan["day"].toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          children: (dayPlan["meals"] as List)
            .map<Widget>((meal) => _mealTile(meal as Map<String, dynamic>))
            .toList(),

        ),
      ),
    );
  }

  /// ================= MEAL TILE =================
  Widget _mealTile(Map<String, dynamic> meal) {
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: AppColors.primary,
        child: Text(
          meal["mealNumber"].toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        meal["description"],
        style: const TextStyle(fontSize: 14),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    );
  }
}
