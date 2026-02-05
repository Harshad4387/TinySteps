import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../widgets/pastel_card.dart';

class ReminderListPage extends StatelessWidget {
  final List reminders;

  const ReminderListPage({
    super.key,
    required this.reminders,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      /// 🌸 APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: const Text(
          "Today's Reminders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: reminders.isEmpty
          ? _emptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final r = reminders[index];
                final time = DateTime.parse(r['reminderTime']);

                return PastelCard(
                  color: _reminderColor(r['type']).withOpacity(0.25),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// ICON BADGE
                      CircleAvatar(
                        radius: 22,
                        backgroundColor:
                            _reminderColor(r['type']),
                        child: Icon(
                          _reminderIcon(r['type']),
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 14),

                      /// TEXT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r['title'] ?? "Reminder",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),

                            /// TIME CHIP
                            Chip(
                              label: Text(
                                "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
                              ),
                              backgroundColor:
                                  Colors.white.withOpacity(0.7),
                              visualDensity:
                                  VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  /// ================= EMPTY STATE =================

  Widget _emptyState() {
    return Center(
      child: PastelCard(
        color: AppColors.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.green,
            ),
            SizedBox(height: 12),
            Text(
              "No reminders for today 🎉",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "You're all caught up!",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= HELPERS =================

IconData _reminderIcon(String? type) {
  switch (type) {
    case "feeding":
      return Icons.restaurant;
    case "medicine":
      return Icons.medication_outlined;
    case "vaccine":
      return Icons.vaccines_outlined;
    default:
      return Icons.alarm;
  }
}

Color _reminderColor(String? type) {
  switch (type) {
    case "feeding":
      return AppColors.pinkSoft;
    case "medicine":
      return AppColors.lavenderSoft;
    case "vaccine":
      return AppColors.peachSoft;
    default:
      return AppColors.mintSoft;
  }
}
