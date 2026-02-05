import 'package:flutter/material.dart';

import '../../services_2/awareness.service_2.dart';
import '../../widgets/pastel_card.dart';
import '../../theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';


class InfantAwarenessScreen extends StatefulWidget {
  const InfantAwarenessScreen({super.key});

  @override
  State<InfantAwarenessScreen> createState() =>
      _InfantAwarenessScreenState();
}

class _InfantAwarenessScreenState extends State<InfantAwarenessScreen> {
  bool loading = false;
  Map<String, dynamic>? analysis;

  int? ageMonths;
  int? feverDays;

  bool premature = false;
  bool vaccinated = false;
  bool allowHomeRemedy = false;

  String? fever;
  String? vomiting;
  String? diarrhea;
  String? cough;
  String? breathing;

  String? city;
  String? pincode;

  Future<void> openMapsNavigation(double lat, double lng) async {
    final url =
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng";

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // opens Google Maps app
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }


  /// ================= BACK HANDLER =================
  Future<bool> _onWillPop() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return false;
    }
    return false; // never exit app
  }

  /// ================= SUBMIT =================
  Future<void> submit() async {
    if (ageMonths == null ||
        feverDays == null ||
        fever == null ||
        vomiting == null ||
        diarrhea == null ||
        cough == null ||
        breathing == null ||
        city == null ||
        pincode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => loading = true);

    final payload = {
      "infant_age_months": ageMonths,
      "premature_birth": premature,
      "vaccinated": vaccinated,
      "symptoms": {
        "fever": fever,
        "fever_duration_days": feverDays,
        "vomiting": vomiting,
        "diarrhea": diarrhea,
        "cough": cough,
        "breathing_difficulty": breathing,
      },
      "location": {
        "city": city,
        "pincode": pincode,
      },
      "allow_home_remedies": allowHomeRemedy,
    };

    final res = await InfantAwarenessService.checkRisk(payload);

    if (!mounted) return;

    setState(() {
      analysis = res?["analysis"];
      loading = false;
    });

    if (res == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to analyze. Try again.")),
      );
    }
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    final risky = analysis?["riskStatus"] == "Risky";

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,

        /// 🌸 APP BAR
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          title: const Text(
            "Infant Risk Awareness",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => _onWillPop(),
          ),
        ),

        body: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _cardSection(
                    "Basic Information",
                    [
                      _numberField("Infant Age (months)",
                          (v) => ageMonths = int.tryParse(v)),
                      _numberField("Fever Duration (days)",
                          (v) => feverDays = int.tryParse(v)),
                    ],
                  ),

                  _cardSection(
                    "Symptoms",
                    [
                      _dropdown("Fever", ["Normal", "≥38°C", "≥39°C"],
                          (v) => fever = v),
                      _dropdown("Vomiting",
                          ["None", "Occasional", "Frequent"],
                          (v) => vomiting = v),
                      _dropdown("Diarrhea",
                          ["Mild", "Moderate", "Severe"],
                          (v) => diarrhea = v),
                      _dropdown("Cough",
                          ["Mild", "Moderate", "Severe"],
                          (v) => cough = v),
                      _dropdown("Breathing Difficulty",
                          ["No", "Yes"],
                          (v) => breathing = v),
                    ],
                  ),

                  _cardSection(
                    "Location",
                    [
                      _textField("City", (v) => city = v),
                      _numberField("Pincode", (v) => pincode = v),
                    ],
                  ),

                  _cardSection(
                    "Preferences",
                    [
                      _switch("Premature Birth", premature,
                          (v) => setState(() => premature = v)),
                      _switch("Vaccinated", vaccinated,
                          (v) => setState(() => vaccinated = v)),
                      _switch("Allow Home Remedies", allowHomeRemedy,
                          (v) => setState(() => allowHomeRemedy = v)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: submit,
                      child: const Text(
                        "Analyze Infant Health",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  if (analysis != null) ...[
                    const SizedBox(height: 20),

                    PastelCard(
                      color: risky
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                      child: Text(
                        "Risk Status: ${analysis!["riskStatus"]}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              risky ? Colors.red : Colors.green,
                        ),
                      ),
                    ),

                    if (risky) ...[
                      _resultSection("Summary", analysis!["summary"]),
                      _resultSection("Recommended Action",
                          analysis!["recommendedAction"]),

                      const SizedBox(height: 12),
                      const Text(
                        "Nearby Hospitals",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),

                      ...analysis!["nearbyHospitals"].map<Widget>(
                        (h) => GestureDetector(
                          onTap: () => openMapsNavigation(
                            h["latitude"],
                            h["longitude"],
                          ),
                          child: PastelCard(
                            color: AppColors.primary.withOpacity(0.15),
                            child: ListTile(
                              leading: const Icon(
                                Icons.local_hospital,
                                color: AppColors.primary,
                              ),
                              title: Text(
                                h["name"],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: const Text("Tap to navigate via Google Maps"),
                              trailing: const Icon(Icons.navigation),
                            ),
                          ),
                        ),
                      ).toList(),
                    ],
                  ],
                ],
              ),
      ),
    );
  }

  /// ================= UI HELPERS =================

  Widget _cardSection(String title, List<Widget> children) {
    return PastelCard(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _numberField(String label, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: _inputDecoration(label),
        onChanged: onChanged,
      ),
    );
  }

  Widget _textField(String label, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: _inputDecoration(label),
        onChanged: onChanged,
      ),
    );
  }

  Widget _dropdown(
      String label, List<String> items, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: _inputDecoration(label),
        items: items
            .map((e) =>
                DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }

  Widget _switch(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      activeColor: AppColors.primary,
      onChanged: onChanged,
    );
  }

  Widget _resultSection(String title, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: PastelCard(
        color: AppColors.peachSoft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(text),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
