import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/data/pregnancy_defaults.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/config/api.dart';
import 'package:frontend/models/pregnancy_models.dart';
import 'package:frontend/services/auth_storage.dart';
import 'package:frontend/theme/colors.dart';
import 'package:frontend/widgets/pastel_card.dart';

enum AddSection { checklist, tests }

class PregnancyScreen extends StatefulWidget {
  const PregnancyScreen({super.key});

  @override
  State<PregnancyScreen> createState() => _PregnancyScreenState();
}

class _PregnancyScreenState extends State<PregnancyScreen> {
  int selectedMonth = 7;
  PregnancyBackendData? backendData;

  String? parentId;
  bool loading = false;

  final TextEditingController checklistController = TextEditingController();
  final TextEditingController testNameController = TextEditingController();
  DateTime? selectedTestDate;

  AddSection selectedSection = AddSection.checklist;

  @override
  void initState() {
    super.initState();
    _loadParent();
  }

  Future<void> _loadParent() async {
    final user = await AuthStorage.getUser();
    parentId = user?['id'] ?? user?['_id'];
    fetchMonthData();
  }

  Future<void> fetchMonthData() async {
    if (parentId == null) return;
    setState(() => loading = true);

    try {
      final res = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}${ApiConfig.monthlyPregnancy}/$selectedMonth?parentId=$parentId",
        ),
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        backendData = PregnancyBackendData.fromJson(json['data']);
      } else {
        backendData = null;
      }
    } catch (_) {
      backendData = null;
    } finally {
      setState(() => loading = false);
    }
  }

  /// ================= UI =================
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
          "Pregnancy Care",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                /// 🤰 MONTH SELECTOR
                SizedBox(
                  height: 46,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 9,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final month = i + 1;
                      final selected = selectedMonth == month;
                      return ChoiceChip(
                        label: Text("Month $month"),
                        selected: selected,
                        selectedColor:
                            AppColors.primary.withOpacity(0.2),
                        onSelected: (_) {
                          setState(() => selectedMonth = month);
                          fetchMonthData();
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                /// ✅ CHECKLIST
                _cardSection(
                  title: "Checklist",
                  onAdd: () => _openAddSheet(AddSection.checklist),
                  child: Column(
                    children: (backendData?.checklist ?? [])
                        .map(
                          (c) => ListTile(
                            leading: Icon(
                              c.done
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: c.done
                                  ? Colors.green
                                  : AppColors.textSecondary,
                            ),
                            title: Text(
                              c.item,
                              style: TextStyle(
                                decoration: c.done
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            onTap: () => _toggleChecklist(c),
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 16),

                /// 🧪 TESTS & SCANS
                _cardSection(
                  title: "Tests & Scans",
                  onAdd: () => _openAddSheet(AddSection.tests),
                  child: Column(
                    children: (backendData?.testsAndScans ?? [])
                        .map(
                          (t) => ListTile(
                            leading: const Icon(
                              Icons.medical_services_outlined,
                              color: AppColors.primary,
                            ),
                            title: Text(t.name),
                            subtitle: Text("Date: ${t.date}"),
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 16),

                /// 🥗 NUTRITION
                _infoSection(
                  "Nutrition Tips",
                  PregnancyDefaults.nutritionTips,
                  AppColors.mintSoft,
                ),

                /// ⚠️ RISK FACTORS
                _infoSection(
                  "Risk Factors",
                  PregnancyDefaults.riskFactors,
                  AppColors.peachSoft,
                ),
              ],
            ),
    );
  }

  /// ================= ACTIONS =================

  Future<void> _toggleChecklist(ChecklistItem item) async {
    if (backendData == null || parentId == null) return;

    setState(() => item.done = !item.done);

    final payload = {
      "parentId": parentId,
      "month": selectedMonth,
      "checklist": backendData!.checklist
          .map((c) => {"item": c.item, "done": c.done})
          .toList(),
    };

    await http.post(
      Uri.parse(ApiConfig.baseUrl + ApiConfig.pregnancyAdd),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );
  }

  void _openAddSheet(AddSection section) {
    selectedSection = section;

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
          children: [
            Text(
              section == AddSection.checklist
                  ? "Add Checklist Item"
                  : "Add Test / Scan",
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (section == AddSection.checklist)
              _input(
                controller: checklistController,
                hint: "Checklist item",
              ),

            if (section == AddSection.tests) ...[
              _input(
                controller: testNameController,
                hint: "Test / Scan name",
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  selectedTestDate == null
                      ? "Select date"
                      : selectedTestDate!
                          .toIso8601String()
                          .split("T")[0],
                ),
                onPressed: _pickTestDate,
              ),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _addItem,
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTestDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 300)),
    );
    if (picked != null) setState(() => selectedTestDate = picked);
  }

  Future<void> _addItem() async {
    if (parentId == null) return;

    final payload = {
      "parentId": parentId,
      "month": selectedMonth,
      "checklist": [],
      "testsAndScans": [],
    };

    if (selectedSection == AddSection.checklist &&
        checklistController.text.isNotEmpty) {
      payload["checklist"] = [
        {"item": checklistController.text, "done": false}
      ];
    }

    if (selectedSection == AddSection.tests &&
        testNameController.text.isNotEmpty &&
        selectedTestDate != null) {
      payload["testsAndScans"] = [
        {
          "name": testNameController.text,
          "date": selectedTestDate!
              .toIso8601String()
              .split("T")[0],
        }
      ];
    }

    final res = await http.post(
      Uri.parse(ApiConfig.baseUrl + ApiConfig.pregnancyAdd),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final json = jsonDecode(res.body);
      backendData = PregnancyBackendData.fromJson(json['data']);
      setState(() {});
    }

    checklistController.clear();
    testNameController.clear();
    selectedTestDate = null;
    Navigator.pop(context);
  }

  /// ================= UI HELPERS =================

  Widget _cardSection({
    required String title,
    required VoidCallback onAdd,
    required Widget child,
  }) {
    return PastelCard(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style:
                      const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: onAdd,
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _infoSection(
      String title, List<String> items, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PastelCard(
        color: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...items.map((e) => Text("• $e")),
          ],
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
