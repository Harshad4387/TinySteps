import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../widgets/pastel_card.dart';
import '../../models/sleep_enty_model.dart';

enum TrackerMode { feeding, sleep }
enum FeedType { breast, formula, solid }

class FeedingEntry {
  final DateTime time;
  final String type;
  final String quantity;
  final String? notes;

  FeedingEntry({
    required this.time,
    required this.type,
    required this.quantity,
    this.notes,
  });
}

class InfantTrackerScreen extends StatefulWidget {
  final String infantId;

  const InfantTrackerScreen({
    super.key,
    required this.infantId,
  });

  @override
  State<InfantTrackerScreen> createState() => _InfantTrackerScreenState();
}

class _InfantTrackerScreenState extends State<InfantTrackerScreen> {
  TrackerMode currentMode = TrackerMode.feeding;

  // Feeding state - LOCAL LIST
  List<FeedingEntry> feeds = [];
  FeedType selectedType = FeedType.breast;
  final TextEditingController quantityCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();
  TimeOfDay? selectedTime;

  // Sleep state - LOCAL LIST
  List<SleepEntry> logs = [];
  DateTime? sleepStartUtc;
  DateTime? sleepEndUtc;

  @override
  void dispose() {
    quantityCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  // ================= FEEDING METHODS =================

  void addFeed() {
    if (selectedTime == null || quantityCtrl.text.isEmpty) return;

    // Create DateTime from selected time
    final now = DateTime.now();
    final feedingDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    // Add to local list
    setState(() {
      feeds.add(
        FeedingEntry(
          time: feedingDateTime,
          type: _feedTypeLabel(selectedType),
          quantity: quantityCtrl.text,
          notes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
        ),
      );
      
      // Sort by time (most recent first)
      feeds.sort((a, b) => b.time.compareTo(a.time));
    });

    // Close bottom sheet and clear form
    Navigator.pop(context);
    quantityCtrl.clear();
    notesCtrl.clear();
    selectedTime = null;
  }

  void openAddFeedSheet() {
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Add Feeding",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              _label("Time"),
              OutlinedButton.icon(
                icon: const Icon(Icons.access_time),
                label: Text(
                  selectedTime == null
                      ? "Select Time"
                      : selectedTime!.format(context),
                ),
                onPressed: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (t != null) setState(() => selectedTime = t);
                },
              ),

              const SizedBox(height: 16),

              _label("Feed Type"),
              Wrap(
                spacing: 10,
                children: FeedType.values.map((type) {
                  final selected = selectedType == type;
                  return ChoiceChip(
                    label: Text(_feedTypeLabel(type)),
                    selected: selected,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    onSelected: (_) => setState(() => selectedType = type),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              _label("Quantity"),
              _input(
                controller: quantityCtrl,
                hint: "e.g. 120 ml / 30 g",
              ),

              const SizedBox(height: 12),

              _input(
                controller: notesCtrl,
                hint: "Notes (optional)",
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
                  onPressed: addFeed,
                  child: const Text(
                    "Save Feeding",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SLEEP METHODS =================

  DateTime toIST(DateTime dt) {
    if (dt.isUtc) {
      return dt.add(const Duration(hours: 5, minutes: 30));
    }
    return dt.toLocal();
  }

  DateTime toUTC(DateTime dt) {
    return dt.toUtc();
  }

  double _calculateHours(DateTime start, DateTime end) {
    final duration = end.difference(start);
    return duration.inMinutes / 60.0;
  }

  double get totalSleepHours {
    double total = 0;
    for (var log in logs) {
      total += log.totalHours;
    }
    return double.parse(total.toStringAsFixed(1));
  }

  void addSleep() {
    if (sleepStartUtc == null || sleepEndUtc == null) return;

    DateTime start = sleepStartUtc!;
    DateTime end = sleepEndUtc!;

    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }

    final hours = _calculateHours(start, end);

    // Add to local list
    setState(() {
      logs.add(
        SleepEntry(
          start: start,
          end: end,
          totalHours: double.parse(hours.toStringAsFixed(1)),
        ),
      );
      
      // Sort by start time (most recent first)
      logs.sort((a, b) => b.start.compareTo(a.start));
    });

    // Close bottom sheet and clear form
    Navigator.pop(context);
    sleepStartUtc = null;
    sleepEndUtc = null;
  }

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

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: const Text(
          "Infant Tracker",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: currentMode == TrackerMode.feeding
                ? openAddFeedSheet
                : openAddSleepSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Toggle Switch
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => currentMode = TrackerMode.feeding),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: currentMode == TrackerMode.feeding
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            "Feeding",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: currentMode == TrackerMode.feeding
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => currentMode = TrackerMode.sleep),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: currentMode == TrackerMode.sleep
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            "Sleep",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: currentMode == TrackerMode.sleep
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: currentMode == TrackerMode.feeding
                ? _buildFeedingView()
                : _buildSleepView(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingView() {
    if (feeds.isEmpty) {
      return const Center(
        child: Text(
          "No feeding recorded today\nTap + to add one",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: feeds.map(_feedTile).toList(),
    );
  }

  Widget _buildSleepView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
              "$totalSleepHours hrs",
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
              "No sleep recorded today\nTap + to add one",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),

        ...logs.map(_sleepLogTile),
      ],
    );
  }

  // ================= UI HELPERS =================

  Widget _feedTile(FeedingEntry feed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PastelCard(
        color: _feedColor(feed.type).withOpacity(0.25),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _feedColor(feed.type),
            child: Icon(
              _feedIcon(feed.type),
              color: Colors.white,
            ),
          ),
          title: Text(
            feed.type,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            "${feed.time.hour.toString().padLeft(2, '0')}:${feed.time.minute.toString().padLeft(2, '0')}",
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          trailing: Text(
            feed.quantity,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sleepLogTile(SleepEntry log) {
    final startIST = toIST(log.start);
    final endIST = toIST(log.end);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PastelCard(
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

  Widget _input({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
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
          borderRadius: BorderRadius.circular(14),
        ),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
      ),
      onPressed: onTap,
    );
  }
}

// ================= HELPERS =================

String _feedTypeLabel(FeedType type) {
  switch (type) {
    case FeedType.breast:
      return "Breast milk";
    case FeedType.formula:
      return "Formula";
    case FeedType.solid:
      return "Solid food";
  }
}

IconData _feedIcon(String type) {
  if (type == "Breast milk") return Icons.water_drop;
  if (type == "Formula") return Icons.child_friendly;
  return Icons.restaurant;
}

Color _feedColor(String type) {
  if (type == "Breast milk") return AppColors.primary;
  if (type == "Formula") return Colors.blue;
  return AppColors.mintSoft;
}

String _formatTime(DateTime t) {
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final period = t.hour >= 12 ? "PM" : "AM";
  final minute = t.minute.toString().padLeft(2, '0');

  return "$hour:$minute $period";
}

String _formatDateTime(DateTime t) =>
    "${t.day}/${t.month}  ${_formatTime(t)}";