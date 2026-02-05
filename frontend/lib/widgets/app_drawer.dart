import 'package:flutter/material.dart';

import 'package:frontend/screens/AppDrawerPages/Infant_Diet_Planner.dart';
import 'package:frontend/screens/AppDrawerPages/Infant_Risk_Analyzer.dart';
import 'package:frontend/screens/AppDrawerPages/Infant_tracker.dart';
import 'package:frontend/screens/AppDrawerPages/baby_product.dart';
import 'package:frontend/screens/AppDrawerPages/feeding_tracker.dart';
import 'package:frontend/screens/AppDrawerPages/medicine_search_page.dart';
import 'package:frontend/screens/AppDrawerPages/pregnancy_care.dart';
import 'package:frontend/screens/AppDrawerPages/recommendation_screen.dart';
import 'package:frontend/screens/AppDrawerPages/sleep_tracker.dart';
import 'package:frontend/screens/AppDrawerPages/vaccinations.dart';
import 'package:frontend/screens/dashboard/milestone_page.dart';

import '../theme/colors.dart';
import '../services/auth_storage.dart';
import '../screens/login_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(26)),
      ),
      child: Column(
        children: [
          /// 🌸 HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.85),
                  AppColors.lavenderSoft,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(26),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.child_friendly,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sarah Miller",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Mother • Emma (6 months)",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          /// 📋 SCROLLABLE MENU ITEMS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                /// 🧭 MAIN
                _sectionTitle("Main"),
                _drawerItem(
                  context,
                  Icons.dashboard_outlined,
                  "Dashboard",
                  () => Navigator.pop(context),
                ),

                /// 🤰 CARE
                _sectionTitle("Care"),
                _drawerItem(
                  context,
                  Icons.favorite_outline,
                  "Pregnancy Care",
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PregnancyScreen()),
                    );
                  },
                ),
                _drawerItem(
                  context,
                  Icons.restaurant_menu_outlined,
                  "Infant Tracker",
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const InfantTrackerScreen(infantId: '',),
                      ),
                    );
                  },
                ),
                
                _drawerItem(
                  context,
                  Icons.vaccines_outlined,
                  "Vaccinations",
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VaccinationPage(),
                      ),
                    );
                  },
                ),

                /// 🧠 SMART TOOLS
                _sectionTitle("Smart Tools"),
                _drawerItem(
                  context,
                  Icons.health_and_safety_outlined,
                  "Infant Health Risk Analyzer",
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InfantAwarenessScreen(),
                      ),
                    );
                  },
                ),
                _drawerItem(
                  context,
                  Icons.vaccines_outlined,
                  "Search Medicine",
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MedicineSearchPage(),
                      ),
                    );
                  },
                ),
                //RecommendationFormScreen
                _drawerItem(
                  context,
                  Icons.menu_book_outlined,
                  "Product Recommendations",
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecommendationFormScreen(),
                      ),
                    );
                  },
                ),

                _drawerItem(
                  context,
                  Icons.menu_book_outlined,
                  "Infant Diet Planner",
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InfantDietPlannerScreen(),
                      ),
                    );
                  },
                ),

                /// 🎯 OTHERS
                _sectionTitle("Others"),
                _drawerItem(context, Icons.flag_outlined, "Milestones", () {Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MilestonePage(),
                      ),
                    );
                    }), //MilestonePage
                
              ],
            ),
          ),

          const Divider(height: 1),

          /// 🚪 LOGOUT
          _drawerItem(
            context,
            Icons.logout,
            "Logout",
            () async {
              await AuthStorage.clear();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            isLogout: true,
          ),

          

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// ---------- HELPERS ----------

  static Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  static Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : AppColors.textPrimary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red : AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 8,
    );
  }
}
