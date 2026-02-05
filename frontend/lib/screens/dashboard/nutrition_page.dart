import 'package:flutter/material.dart';
import 'package:frontend/screens/dashboard/food_analysis_screen.dart';
import '../../theme/colors.dart';
import '../../widgets/pastel_card.dart';

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("Pregnancy Nutrition Guide"),

          _infoCard(
            icon: Icons.egg_alt_outlined,
            title: "Protein",
            color: AppColors.peachSoft,
            description:
                "Helps fetal growth and maternal tissue repair.\n\nRecommended: Eggs, paneer, lentils, dairy, nuts.",
          ),

          _infoCard(
            icon: Icons.local_drink_outlined,
            title: "Calcium",
            color: const Color.fromARGB(255, 188, 228, 255),
            description:
                "Supports baby's bone and teeth development.\n\nRecommended: Milk, curd, paneer, ragi, sesame seeds.",
          ),

          _infoCard(
            icon: Icons.favorite_outline,
            title: "Iron",
            color: AppColors.mintSoft,
            description:
                "Prevents anemia and supports oxygen supply.\n\nRecommended: Spinach, beetroot, dates, legumes.",
          ),

          _infoCard(
            icon: Icons.spa_outlined,
            title: "Folic Acid",
            color: AppColors.lavenderSoft,
            description:
                "Prevents neural tube defects.\n\nRecommended: Green leafy vegetables, citrus fruits.",
          ),

          _infoCard(
            icon: Icons.opacity_outlined,
            title: "Healthy Fats",
            color: AppColors.peachSoft,
            description:
                "Important for brain development.\n\nRecommended: Nuts, seeds, ghee (in moderation).",
          ),

          const SizedBox(height: 28),

          /// 📸 FOOD ANALYZER CTA
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                "Analyze My Food",
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FoodAnalysisScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ================= UI HELPERS =================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: PastelCard(
        color: color,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
