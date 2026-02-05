import 'package:flutter/material.dart';
import 'package:frontend/screens/AppDrawerPages/Infant_Risk_Analyzer.dart';
import 'package:frontend/theme/colors.dart';

class DiseasePage extends StatelessWidget {
  const DiseasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// 🔝 CUSTOM HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Disease Awareness",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.medical_services_outlined),
                  tooltip: "Consult Doctor / Specialist",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InfantAwarenessScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 🦠 DISEASE LIST
            ...diseases.map(
              (disease) => DiseaseCard(disease: disease),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= DISEASE CARD =================

class DiseaseCard extends StatelessWidget {
  final Disease disease;

  const DiseaseCard({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    final severity = _severityConfig(disease.severity);

    return Card(
      color: AppColors.surface,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: severity.color.withOpacity(0.15),
                  child: Icon(disease.icon, color: severity.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    disease.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: severity.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    severity.label,
                    style: TextStyle(
                      color: severity.color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            /// SYMPTOMS
            const Text(
              "Symptoms",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: disease.symptoms
                  .map(
                    (s) => Chip(
                      label: Text(
                        s,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 14),

            /// PRECAUTIONS
            const Text(
              "Precautions",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...disease.precautions.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 16, color: Colors.green),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        p,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            /// DOCTOR VISIT
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      disease.doctorVisit,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= DATA MODEL =================

class Disease {
  final String name;
  final IconData icon;
  final String severity;
  final List<String> symptoms;
  final List<String> precautions;
  final String doctorVisit;

  Disease({
    required this.name,
    required this.icon,
    required this.severity,
    required this.symptoms,
    required this.precautions,
    required this.doctorVisit,
  });
}

/// ================= DISEASE DATA =================

final List<Disease> diseases = [
  Disease(
    name: "Common Cold",
    icon: Icons.air,
    severity: "mild",
    symptoms: ["Runny nose", "Sneezing", "Mild cough", "Low fever"],
    precautions: [
      "Use saline drops",
      "Keep baby hydrated",
      "Humidifier use",
      "Gentle nasal suction",
    ],
    doctorVisit:
        "If symptoms last more than 10 days or fever exceeds 100.4°F",
  ),
  Disease(
    name: "Ear Infection",
    icon: Icons.hearing,
    severity: "moderate",
    symptoms: [
      "Pulling ears",
      "Fussiness",
      "Sleep difficulty",
      "Fever"
    ],
    precautions: [
      "Keep ears dry",
      "Avoid smoke exposure",
      "Breastfeed if possible",
    ],
    doctorVisit: "Visit doctor within 24–48 hours if symptoms appear",
  ),
  Disease(
    name: "Fever",
    icon: Icons.thermostat,
    severity: "moderate",
    symptoms: [
      "High temperature",
      "Flushed skin",
      "Poor appetite",
      "Irritability"
    ],
    precautions: [
      "Lukewarm sponge bath",
      "Light clothing",
      "Plenty of fluids",
    ],
    doctorVisit:
        "Immediately if baby is under 3 months with fever above 100.4°F",
  ),
  Disease(
    name: "Diaper Rash",
    icon: Icons.child_care,
    severity: "mild",
    symptoms: ["Red skin", "Irritation", "Discomfort"],
    precautions: [
      "Frequent diaper changes",
      "Zinc oxide cream",
      "Allow air-dry time",
    ],
    doctorVisit: "If rash doesn’t improve in 3 days or worsens",
  ),
];

/// ================= SEVERITY CONFIG =================

class SeverityConfig {
  final Color color;
  final String label;

  SeverityConfig(this.color, this.label);
}

SeverityConfig _severityConfig(String severity) {
  switch (severity) {
    case "mild":
      return SeverityConfig(Colors.green, "Mild");
    case "moderate":
      return SeverityConfig(Colors.orange, "Moderate");
    case "severe":
      return SeverityConfig(Colors.red, "Severe");
    default:
      return SeverityConfig(Colors.grey, severity);
  }
}
