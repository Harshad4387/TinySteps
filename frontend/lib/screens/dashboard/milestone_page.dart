import 'package:flutter/material.dart';
import 'package:frontend/theme/colors.dart';
import '../../services/milestone.service.dart';

/// ================= MODEL =================
class Milestone {
  final String id;
  final String milestoneType;
  final DateTime dateAchieved;
  final String? notes;

  Milestone({
    required this.id,
    required this.milestoneType,
    required this.dateAchieved,
    this.notes,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['_id'],
      milestoneType: json['milestoneType'],
      dateAchieved: DateTime.parse(json['dateAchieved']),
      notes: json['notes'],
    );
  }
}

/// ================= PAGE =================
class MilestonePage extends StatefulWidget {
  const MilestonePage({super.key});

  @override
  State<MilestonePage> createState() => _MilestonePageState();
}

class _MilestonePageState extends State<MilestonePage> {
  bool loading = true;
  List<Milestone> milestones = [];

  @override
  void initState() {
    super.initState();
    fetchMilestones();
  }

  Future<void> fetchMilestones() async {
    setState(() => loading = true);

    final data = await MilestoneService.fetchMilestones();
    milestones = data.map((e) => Milestone.fromJson(e)).toList();

    setState(() => loading = false);
  }


  void openAddMilestoneSheet() {
  final typeCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  DateTime? selectedDate;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => StatefulBuilder(
      builder: (context, setSheetState) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ─── DRAG HANDLE ───
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            /// 🏁 TITLE
            const Text(
              "Add Milestone",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Capture a special moment in your baby’s journey",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// 🏷️ MILESTONE TYPE
            TextField(
              controller: typeCtrl,
              decoration: _inputDecoration(
                "Milestone (e.g. First Smile)",
                icon: Icons.flag_outlined,
              ),
            ),

            const SizedBox(height: 12),

            /// 📅 DATE PICKER (FIELD STYLE)
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  initialDate: DateTime.now(),
                );
                if (d != null) {
                  setSheetState(() => selectedDate = d);
                }
              },
              child: InputDecorator(
                decoration: _inputDecoration(
                  "Date Achieved",
                  icon: Icons.calendar_today,
                ),
                child: Text(
                  selectedDate == null
                      ? "Select date"
                      : selectedDate!
                          .toLocal()
                          .toString()
                          .split(' ')[0],
                  style: TextStyle(
                    color: selectedDate == null
                        ? Colors.grey
                        : Colors.black87,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// 📝 NOTES
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: _inputDecoration(
                "Notes (optional)",
                icon: Icons.notes_outlined,
              ),
            ),

            const SizedBox(height: 20),

            /// 💾 SAVE BUTTON
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
                onPressed: () async {
                  if (typeCtrl.text.isEmpty || selectedDate == null) return;

                  final success = await MilestoneService.addMilestone(
                    milestoneType: typeCtrl.text,
                    dateAchieved: selectedDate!,
                    notes: notesCtrl.text,
                  );

                  if (success) {
                    Navigator.pop(context);
                    fetchMilestones();
                  }
                },
                child: const Text(
                  "Save Milestone",
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

/// ================= INPUT DECORATION =================
InputDecoration _inputDecoration(String label, {IconData? icon}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: icon != null ? Icon(icon) : null,
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  );
}


  /// ================= UI =================
  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Column(
        children: [
          /// 🔝 CUSTOM HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Milestones",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.primary,
                  onPressed: openAddMilestoneSheet,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          /// 📋 BODY
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : milestones.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: milestones.length,
                        itemBuilder: (_, index) {
                          final m = milestones[index];
                          return _TimelineTile(
                            milestone: m,
                            isFirst: index == 0,
                            isLast: index == milestones.length - 1,
                          );
                        },
                      ),
          ),
        ],
      ),
    ),
  );
}
Widget _emptyState() {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.flag_outlined, size: 48, color: Colors.grey),
        SizedBox(height: 12),
        Text(
          "No milestones added yet",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Capture your baby’s special moments ✨",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    ),
  );
}

}

/// ================= TIMELINE TILE =================
class _TimelineTile extends StatelessWidget {
  final Milestone milestone;
  final bool isFirst;
  final bool isLast;

  const _TimelineTile({
    required this.milestone,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TIMELINE
          Column(
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 20,
                  color: AppColors.primary.withOpacity(0.4),
                ),

              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),

              if (!isLast)
                Container(
                  width: 2,
                  height: 70,
                  color: AppColors.primary.withOpacity(0.4),
                ),
            ],
          ),

          const SizedBox(width: 14),

          /// CONTENT CARD
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.milestoneType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        milestone.dateAchieved
                            .toLocal()
                            .toString()
                            .split(' ')[0],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  if (milestone.notes != null &&
                      milestone.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      milestone.notes!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

