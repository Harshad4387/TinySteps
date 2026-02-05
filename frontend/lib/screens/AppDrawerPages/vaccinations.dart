import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../services/vaccination_service.dart';
import '../../widgets/pastel_card.dart';

class VaccinationPage extends StatefulWidget {
  const VaccinationPage({super.key});

  @override
  State<VaccinationPage> createState() => _VaccinationPageState();
}

class _VaccinationPageState extends State<VaccinationPage> {
  bool _loading = true;
  List<dynamic> _records = [];

  @override
  void initState() {
    super.initState();
    _loadVaccinations();
  }

  Future<void> _loadVaccinations() async {
    if (!mounted) return;

    setState(() => _loading = true);
    try {
      final data = await VaccinationService.getAllVaccinations();
      if (!mounted) return;
      setState(() => _records = data);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to load vaccinations")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "Missed":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  /// ================= ADD VACCINATION =================
  void _openAddDialog() {
    final nameCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    DateTime selectedDate = DateTime.now();
    String status = "Pending";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (_, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                20,
                16,
                MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Add Vaccination",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _input(nameCtrl, "Vaccine Name"),
                  const SizedBox(height: 12),
                  _input(notesCtrl, "Notes (optional)"),

                  const SizedBox(height: 12),

                  _label("Due Date"),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      selectedDate.toIso8601String().split("T")[0],
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: sheetContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  _label("Status"),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: _decoration(""),
                    items: const [
                      DropdownMenuItem(
                          value: "Pending", child: Text("Pending")),
                      DropdownMenuItem(
                          value: "Completed", child: Text("Completed")),
                      DropdownMenuItem(
                          value: "Missed", child: Text("Missed")),
                    ],
                    onChanged: (v) =>
                        setModalState(() => status = v!),
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
                      onPressed: () async {
                        if (nameCtrl.text.trim().isEmpty) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Vaccine name is required")),
                          );
                          return;
                        }

                        try {
                          await VaccinationService.addVaccination(
                            vaccineName: nameCtrl.text.trim(),
                            dueDate: selectedDate,
                            status: status,
                            notes: notesCtrl.text.trim(),
                          );

                          if (!sheetContext.mounted) return;
                          Navigator.pop(sheetContext);
                          _loadVaccinations();
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Failed to add vaccination")),
                          );
                        }
                      },
                      child: const Text(
                        "Save Vaccination",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      nameCtrl.dispose();
      notesCtrl.dispose();
    });
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
          "Vaccinations",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? const Center(
                  child: Text(
                    "No vaccinations added",
                    style:
                        TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadVaccinations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _records.length,
                    itemBuilder: (_, i) {
                      final r = _records[i];
                      final color = _statusColor(r['status']);

                      return PastelCard(
                        color: AppColors.surface,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                color.withOpacity(0.15),
                            child: Icon(
                              Icons.vaccines_outlined,
                              color: color,
                            ),
                          ),
                          title: Text(
                            r['vaccineName'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Due: ${r['dueDate'].split('T')[0]}",
                          ),
                          trailing: Chip(
                            label: Text(r['status']),
                            backgroundColor:
                                color.withOpacity(0.2),
                            labelStyle: TextStyle(color: color),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  /// ================= HELPERS =================

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

  Widget _input(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      decoration: _decoration(hint),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
