import 'package:flutter/material.dart';

import '../../services/sleep_service.dart';
import '../../theme/colors.dart';
import '../../widgets/pastel_card.dart';
import '../../models/sleep_enty_model.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  bool loading = true;
  double totalHours = 0;
  List<SleepEntry> logs = [];

  DateTime? sleepStartUtc;
  DateTime? sleepEndUtc;

  @override
  void initState() {
    super.initState();
    fetchTodaySleep();
  }

  /// ================= TIMEZONE HELPERS =================

  /// Convert UTC → IST
  DateTime toIST(DateTime dt) {
    if (dt.isUtc) {
      return dt.add(const Duration(hours: 5, minutes: 30));
    }
    return dt.toLocal();
  }

  /// Convert Local/IST → UTC (for storage)
  DateTime toUTC(DateTime dt) {
    return dt.toUtc();
  }

  /// ================= FETCH TODAY SLEEP =================
  Future<void> fetchTodaySleep() async {
    setState(() => loading = true);

    final data = await SleepService.getTodaySleep();

    setState(() {
      totalHours = (data['totalHours'] as num).toDouble();
      logs = (data['logs'] as List)
          .map((e) => SleepEntry.fromJson(e))
          .toList();
      loading = false;
    });
  }

  /// ================= ADD SLEEP =================
  Future<void> addSleep() async {
    if (sleepStartUtc == null || sleepEndUtc == null) return;

    DateTime start = sleepStartUtc!;
    DateTime end = sleepEndUtc!;

    /// 🔥 Handle cross-day sleep (e.g. 11 PM → 6 AM)
    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }

    final success = await SleepService.addSleep(
      sleepStart: start,
      sleepEnd: end,
    );

    if (success) {
      Navigator.pop(context);
      sleepStartUtc = null;
      sleepEndUtc = null;
      await fetchTodaySleep();
    }
  }

  /// ================= ADD SLEEP SHEET =================
  void openAddSleepSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          20,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Add Sleep Entry",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            _label("Sleep Start"),
            _timeButton(
              icon: Icons.nights_stay_outlined,
              label: sleepStartUtc == null
                  ? "Select start time"
                  : _formatDateTime(toIST(sleepStartUtc!)),
              onTap: () async {
                final picked = await _pickDateTime();
                if (picked != null) {
                  setState(() => sleepStartUtc = toUTC(picked));
                }
              },
            ),

            const SizedBox(height: 12),

            _label("Sleep End"),
            _timeButton(
              icon: Icons.wb_sunny_outlined,
              label: sleepEndUtc == null
                  ? "Select end time"
                  : _formatDateTime(toIST(sleepEndUtc!)),
              onTap: () async {
                final picked = await _pickDateTime();
                if (picked != null) {
                  setState(() => sleepEndUtc = toUTC(picked));
                }
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: addSleep,
                child: const Text(
                  "Save Sleep",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= DATE TIME PICKER =================
  Future<DateTime?> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now(),
    );

    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (time == null) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: const Text(
          "Sleep Tracker",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: openAddSleepSheet,
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                /// 🛌 TOTAL SLEEP
                PastelCard(
                  color: AppColors.lavenderSoft,
                  child: ListTile(
                    leading: const Icon(
                      Icons.bedtime_outlined,
                      size: 28,
                      color: AppColors.primary,
                    ),
                    title: const Text("Total Sleep Today"),
                    trailing: Text(
                      "$totalHours hrs",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (logs.isEmpty)
                  const Center(
                    child: Text(
                      "No sleep recorded today",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),

                ...logs.map(_sleepLogTile),
              ],
            ),
    );
  }

  /// ================= UI HELPERS =================

  Widget _sleepLogTile(SleepEntry log) {
    final startIST = toIST(log.start);
    final endIST = toIST(log.end);

    return PastelCard(
      color: AppColors.surface,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.15),
          child: const Icon(
            Icons.nights_stay_outlined,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          "${_formatTime(startIST)} – ${_formatTime(endIST)}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Text(
          "${log.totalHours} hrs",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _timeButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      icon: Icon(icon, color: AppColors.primary),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
      ),
      onPressed: onTap,
    );
  }
}

/// ================= FORMATTERS =================

String _formatTime(DateTime t) {
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final period = t.hour >= 12 ? "PM" : "AM";
  final minute = t.minute.toString().padLeft(2, '0');

  return "$hour:$minute $period";
}

String _formatDateTime(DateTime t) =>
    "${t.day}/${t.month}  ${_formatTime(t)}";
