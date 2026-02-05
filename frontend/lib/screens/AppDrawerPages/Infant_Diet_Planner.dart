import 'package:flutter/material.dart';

import '../../widgets/pastel_card.dart';
import '../../theme/colors.dart';
import '../../services_2/nurition_service.dart';

class InfantDietPlannerScreen extends StatefulWidget {
  const InfantDietPlannerScreen({super.key});

  @override
  State<InfantDietPlannerScreen> createState() =>
      _InfantDietPlannerScreenState();
}

class _InfantDietPlannerScreenState
    extends State<InfantDietPlannerScreen> {
  int? ageMonths;
  double? weightKg;
  int? mealsPerDay;
  int? planDays;

  String feedingType = "Breastfed";
  bool solidsStarted = false;
  String dietPreference = "Vegetarian";
  String region = "India";
  String parentGoal = "";

  bool includeRecipes = true;
  bool includePrecautions = true;

  final TextEditingController allergyCtrl =
      TextEditingController(text: "None");

  bool loading = false;
  Map<String, dynamic>? analysis;

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
          "Infant Diet Planner",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 👶 HEADER CARD
          PastelCard(
            color: AppColors.lavenderSoft,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Provide Infant Details",
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  "We’ll generate a safe, age-appropriate diet plan",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _section(
            "Basic Details",
            [
              _numberField("Infant Age (months)",
                  (v) => ageMonths = int.tryParse(v)),
              _numberField("Weight (kg)",
                  (v) => weightKg = double.tryParse(v)),
              _dropdown(
                "Feeding Type",
                ["Breastfed", "Formula-fed", "Mixed"],
                (v) => feedingType = v,
              ),
              _switch(
                "Solids Started",
                solidsStarted,
                (v) => setState(() => solidsStarted = v),
              ),
            ],
          ),

          _section(
            "Diet Preferences",
            [
              _textField(
                "Allergies (comma separated)",
                allergyCtrl,
              ),
              _dropdown(
                "Diet Preference",
                ["Vegetarian", "Non-Vegetarian"],
                (v) => dietPreference = v,
              ),
              _dropdown(
                "Region",
                ["India", "Global"],
                (v) => region = v,
              ),
              _textField(
                "Parent Goal (e.g. Improve digestion & immunity)",
                null,
                onChanged: (v) => parentGoal = v,
              ),
            ],
          ),

          _section(
            "Plan Configuration",
            [
              _numberField("Meals Per Day",
                  (v) => mealsPerDay = int.tryParse(v)),
              _numberField("Plan Duration (days)",
                  (v) => planDays = int.tryParse(v)),
              _switch(
                "Include Recipes",
                includeRecipes,
                (v) => setState(() => includeRecipes = v),
              ),
              _switch(
                "Include Allergy Precautions",
                includePrecautions,
                (v) => setState(() => includePrecautions = v),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// 🍽 CTA
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _submit,
              child: const Text(
                "Suggest Diet Plan",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          if (loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),

          if (analysis != null) ..._buildResultUI(),
        ],
      ),
    );
  }

  /// ================= SUBMIT =================
  Future<void> _submit() async {
    if (ageMonths == null ||
        weightKg == null ||
        mealsPerDay == null ||
        planDays == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all required fields")),
      );
      return;
    }

    setState(() => loading = true);

    final payload = {
      "infant_age_months": ageMonths,
      "feeding_type": feedingType,
      "solids_started": solidsStarted,
      "allergies": allergyCtrl.text.split(","),
      "weight_kg": weightKg,
      "diet_preference": dietPreference,
      "region": region,
      "parent_goal": parentGoal,
      "meals_per_day": mealsPerDay,
      "plan_duration_days": planDays,
      "include_recipes": includeRecipes,
      "include_allergy_precautions": includePrecautions,
    };

    final res = await NutritionService.getDietPlan(payload);

    setState(() {
      analysis = res?["analysis"];
      loading = false;
    });
  }

  /// ================= RESULT UI =================
  List<Widget> _buildResultUI() {
  final planDuration = analysis?["planDuration"];
  final foodsToAvoid = analysis?["foodsToAvoid"] as List? ?? [];
  final weeklySchedule = analysis?["weeklySchedule"] as List? ?? [];
  final keyTips = analysis?["keyTips"] as List? ?? [];

  return [
    const SizedBox(height: 24),

    /// 📅 PLAN DURATION
    PastelCard(
      color: AppColors.mintSoft,
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(
            "Plan Duration: $planDuration",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),

    const SizedBox(height: 12),

    /// 🚫 FOODS TO AVOID
    if (foodsToAvoid.isNotEmpty)
      PastelCard(
        color: AppColors.peachSoft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Foods To Avoid",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...foodsToAvoid.map((e) => Text("• $e")),
          ],
        ),
      ),

    const SizedBox(height: 20),

    /// 🍼 WEEKLY DIET PLAN
    const Text(
      "Weekly Diet Plan",
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),

    const SizedBox(height: 8),

    ...weeklySchedule.map<Widget>(
      (week) => PastelCard(
        color: AppColors.surface,
        child: ExpansionTile(
          title: Text(
            "Week ${week["week"]}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            "${week["mealsPerDay"]} meals per day",
            style: const TextStyle(fontSize: 12),
          ),
          children: (week["recommendedFoods"] as List)
              .map<Widget>(
                (food) => ListTile(
                  leading: const Icon(
                    Icons.restaurant,
                    color: AppColors.primary,
                  ),
                  title: Text(food),
                ),
              )
              .toList(),
        ),
      ),
    ),

    const SizedBox(height: 20),

    /// 💡 KEY TIPS
    if (keyTips.isNotEmpty)
      PastelCard(
        color: AppColors.lavenderSoft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Key Tips",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...keyTips.map((e) => Text("• $e")),
          ],
        ),
      ),
  ];
}


  /// ================= HELPERS =================

  Widget _section(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PastelCard(
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

  Widget _textField(String label, TextEditingController? controller,
      {Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
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

  Widget _switch(
      String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      activeColor: AppColors.primary,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
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
