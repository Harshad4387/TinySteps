import 'package:flutter/material.dart';
import 'package:frontend/widgets/recommendation_result.dart';
import '../../services/recommendation_service.dart';

class RecommendationFormScreen extends StatefulWidget {
  const RecommendationFormScreen({super.key});

  @override
  State<RecommendationFormScreen> createState() =>
      _RecommendationFormScreenState();
}

class _RecommendationFormScreenState extends State<RecommendationFormScreen> {
  int ageMonths = 32;
  String gender = "Male";
  String season = "Winter";
  String category = "Toys";
  String priceRange = "Medium";
  int safetyLevel = 4;
  int softnessLevel = 5;

  bool loading = false;
  Map<String, dynamic>? response;

  final List<String> genders = ["Male", "Female", "Unisex"];
  final List<String> seasons = ["Winter", "Summer", "All"];
  final List<String> categories = ["Toys", "Clothes", "Accessories", "Food"];
  final List<String> prices = ["Low", "Medium", "High"];

  Future<void> submit() async {
    setState(() {
      loading = true;
      response = null;
    });

    try {
      final res = await RecommendationService.getRecommendations(
        ageMonths: ageMonths,
        gender: gender,
        season: season,
        category: category,
        priceRange: priceRange,
        safetyLevel: safetyLevel,
        softnessLevel: softnessLevel,
      );

      setState(() {
        response = res;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  DropdownButtonFormField<String> buildDropdown(
      String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Baby Product Recommendation")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              initialValue: ageMonths.toString(),
              decoration: const InputDecoration(labelText: "Age (Months)"),
              keyboardType: TextInputType.number,
              onChanged: (v) => ageMonths = int.parse(v),
            ),

            const SizedBox(height: 12),
            buildDropdown("Gender", gender, genders, (v) => setState(() => gender = v!)),
            buildDropdown("Season", season, seasons, (v) => setState(() => season = v!)),
            buildDropdown("Category", category, categories, (v) => setState(() => category = v!)),
            buildDropdown("Price Range", priceRange, prices, (v) => setState(() => priceRange = v!)),

            const SizedBox(height: 16),
            Slider(
              value: safetyLevel.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: "Safety: $safetyLevel",
              onChanged: (v) => setState(() => safetyLevel = v.toInt()),
            ),

            Slider(
              value: softnessLevel.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: "Softness: $softnessLevel",
              onChanged: (v) => setState(() => softnessLevel = v.toInt()),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : submit,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Get Recommendation"),
            ),

            const SizedBox(height: 20),

            if (response != null) RecommendationResult(response!)
          ],
        ),
      ),
    );
  }
}
