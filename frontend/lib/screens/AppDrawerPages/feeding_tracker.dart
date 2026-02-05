import 'package:flutter/material.dart';

import '../../services/feedingservice.dart';
import '../../theme/colors.dart';
import '../../widgets/pastel_card.dart';

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

  factory FeedingEntry.fromJson(Map<String, dynamic> json) {
    return FeedingEntry(
      time: DateTime.parse(json['time']),
      type: json['type'].toString(),
      quantity: json['quantity'].toString(),
      notes: json['notes']?.toString(),
    );
  }
}

class FeedingTrackerScreen extends StatefulWidget {
  final String infantId;

  const FeedingTrackerScreen({
    super.key,
    required this.infantId,
  });

  @override
  State<FeedingTrackerScreen> createState() => _FeedingTrackerScreenState();
}

class _FeedingTrackerScreenState extends State<FeedingTrackerScreen> {
  bool loading = true;
  List<FeedingEntry> feeds = [];

  FeedType selectedType = FeedType.breast;
  final TextEditingController quantityCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    fetchTodayFeeds();
  }

  Future<void> fetchTodayFeeds() async {
    setState(() => loading = true);

    final data =
        await FeedingService.fetchTodayFeeding(widget.infantId);

    setState(() {
      feeds = data.map((e) => FeedingEntry.fromJson(e)).toList();
      loading = false;
    });
  }

  Future<void> addFeed() async {
    if (selectedTime == null || quantityCtrl.text.isEmpty) return;

    // Convert TimeOfDay to HH:mm format for backend
    final timeString =
        "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

    final success = await FeedingService.addFeeding(
      infantId: widget.infantId,
      type: _feedTypeLabel(selectedType),
      quantity: quantityCtrl.text,
      notes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
      times: [timeString],
    );

    if (success) {
      Navigator.pop(context);
      quantityCtrl.clear();
      notesCtrl.clear();
      selectedTime = null;
      await fetchTodayFeeds();
    }
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
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              /// TIME
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

              /// TYPE
              _label("Feed Type"),
              Wrap(
                spacing: 10,
                children: FeedType.values.map((type) {
                  final selected = selectedType == type;
                  return ChoiceChip(
                    label: Text(_feedTypeLabel(type)),
                    selected: selected,
                    selectedColor:
                        AppColors.primary.withOpacity(0.2),
                    onSelected: (_) =>
                        setState(() => selectedType = type),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              /// QUANTITY
              _label("Quantity"),
              _input(
                controller: quantityCtrl,
                hint: "e.g. 120 ml / 30 g",
              ),

              const SizedBox(height: 12),

              /// NOTES
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
          "Feeding Tracker",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: openAddFeedSheet,
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : feeds.isEmpty
              ? const Center(
                  child: Text(
                    "No feeding scheduled for today",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: feeds.map(_feedTile).toList(),
                ),
    );
  }

  /// ================= UI HELPERS =================

  Widget _feedTile(FeedingEntry feed) {
    return PastelCard(
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
}

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
