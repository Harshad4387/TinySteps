import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/depression_service.dart';
import '../../theme/colors.dart';
import '../../widgets/pastel_card.dart';

class DepressionPage extends StatefulWidget {
  const DepressionPage({super.key});

  @override
  State<DepressionPage> createState() => _DepressionPageState();
}

class _DepressionPageState extends State<DepressionPage> {
  final _ageCtrl = TextEditingController();

  /// Dropdown options
  final List<String> options = [
    "No",
    "Sometimes",
    "Yes",
    "Always",
    "Two or more days a week",
  ];

  /// Question → Selected answer
  final Map<String, String> answers = {
    "Feeling sad or tearful": "No",
    "Irritable towards baby & partner": "No",
    "Trouble sleeping at night": "No",
    "Problems concentrating or making decisions": "No",
    "Overeating or loss of appetite": "No",
    "Feeling anxious": "No",
    "Feeling of guilt": "No",
    "Problems bonding with baby": "No",
    "Suicidal thoughts": "No",
  };

  Map<String, dynamic>? result;
  bool loading = false;

  /// ================= ENCODER =================
  /// Converts text answers → numeric (ML-safe)
  // int encodeAnswer(String value) {
  //   switch (value) {
  //     case "No":
  //       return 0;
  //     case "Sometimes":
  //       return 1;
  //     case "Yes":
  //       return 2;
  //     case "Always":
  //     case "Two or more days a week":
  //       return 3;
  //     default:
  //       return 0;
  //   }
  // }

  /// ================= SANITIZER =================
  Map<String, dynamic> cleanPayload(Map<String, dynamic> raw) {
    final cleaned = <String, dynamic>{};

    raw.forEach((key, value) {
      if (value == null) {
        cleaned[key] = 0;
      } else if (value is String && value.isEmpty) {
        cleaned[key] = 0;
      } else {
        cleaned[key] = value;
      }
    });

    return cleaned;
  }

  /// ================= SUBMIT =================
  Future<void> _submit() async {
    if (_ageCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter age")),
      );
      return;
    }

    setState(() => loading = true);

    final payload = {
      "Age": int.tryParse(_ageCtrl.text) ?? 0,
      "Feeling sad or Tearful": answers["Feeling sad or tearful"],
      "Irritable towards baby & partner": answers["Irritable towards baby & partner"],
      "Trouble sleeping at night": answers["Trouble sleeping at night"],
      "Problems concentrating or making decision": answers["Problems concentrating or making decisions"],
      "Overeating or loss of appetite": answers["Overeating or loss of appetite"],
      "Feeling anxious": answers["Feeling anxious"],
      "Feeling of guilt": answers["Feeling of guilt"],
      "Problems of bonding with baby": answers["Problems bonding with baby"],
      "Suicide attempt": answers["Suicidal thoughts"],
    };

    final res = await DepressionService.predictDepression(payload);

    setState(() {
      result = res;
      loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 🧠 INTRO
          PastelCard(
            color: AppColors.pinkSoft,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pregnancy Mental Health Check",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  "Answer honestly. This helps identify emotional well-being and support needs.",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// 👩 AGE
          _section(
            "Basic Information",
            [
              _input(
                controller: _ageCtrl,
                label: "Age",
                keyboardType: TextInputType.number,
              ),
            ],
          ),

          /// ❓ QUESTIONS
          _section(
            "How have you been feeling lately?",
            answers.keys.map((q) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  value: answers[q],
                  decoration: _decoration(q),
                  items: options
                      .map(
                        (o) => DropdownMenuItem(
                          value: o,
                          child: Text(o),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      answers[q] = val!;
                    });
                  },
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          /// 🔍 SUBMIT
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: loading ? null : _submit,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Assess Mental Health",
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),

          const SizedBox(height: 24),

          /// 📊 RESULT
          if (result != null) _ResultCard(result!),
        ],
      ),
    );
  }

  /// ================= UI HELPERS =================

  Widget _section(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PastelCard(
        color: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _decoration(label),
    );
  }

  InputDecoration _decoration(String label) {
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

/// ================= MOTIVATIONAL QUOTES =================
final List<String> motivationalQuotes = [
  "You are not weak for feeling this way. You are strong for acknowledging it.",
  "This phase does not define you — it is only a chapter, not the whole story.",
  "You are doing the best you can, and that is enough for today.",
  "Your feelings are valid, and you deserve care and support.",
  "Healing takes time. Be gentle with yourself.",
  "You are not alone. Help is available and things can improve.",
  "Even the hardest days do not last forever.",
];

/// ================= RESULT CARD =================
class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> result;

  const _ResultCard(this.result);

  @override
  Widget build(BuildContext context) {
    final bool isDepressed = result["predicted_label"] == 1;

    final String? quote = isDepressed
        ? motivationalQuotes[Random().nextInt(motivationalQuotes.length)]
        : null;

    return PastelCard(
      color: isDepressed ? AppColors.pinkSoft : AppColors.mintSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isDepressed
                ? "⚠ Signs of Depression Detected"
                : "✅ No Depression Detected",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDepressed ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          Text("Depression Score: ${result["depression_score"]}"),
          Text(
            "Probability: ${(result["probability_class_1"] * 100).toStringAsFixed(2)}%",
          ),
          if (isDepressed && quote != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              "💬 A message for you",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              quote,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
