import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconly/iconly.dart';

import '../../theme/colors.dart';
import '../../widgets/app_drawer.dart';

import 'home_page.dart';
import 'depression_page.dart';
import 'nutrition_page.dart';
import 'disease_page.dart';
import 'milestone_page.dart';
import 'chatbot_page.dart';

enum SelectedTab { home, depression, nutrition, disease, milestone }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onTabChanged(int index) {
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      /// 🌸 APP BAR
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "TinySteps",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),

      drawer: const AppDrawer(),

      /// 🔁 PAGE VIEW
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          HomePage(),
          DepressionPage(),   // Pregnancy Mental Health
          NutritionPage(),
          DiseasePage(),      // Infant Disease Awareness
          MilestonePage(),
        ],
      ),

      /// 🤖 FLOATING AI BUTTON
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: const Text(
          "Ask AI",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatbotPage()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      /// ⬇️ BOTTOM NAV (GNAV)
      bottomNavigationBar: Container(
  decoration: BoxDecoration(
    color: AppColors.surface,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
      ),
    ],
  ),
  padding: const EdgeInsets.fromLTRB(10, 12, 10, 16), // slightly more bottom
  child: GNav(
    selectedIndex: _selectedIndex,
    onTabChange: _onTabChanged,

    haptic: true,
    rippleColor: AppColors.primary.withOpacity(0.15),
    hoverColor: AppColors.primary.withOpacity(0.08),

    gap: 6,
    iconSize: 26,
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 14,
    ),

    color: AppColors.textSecondary,
    activeColor: AppColors.primary,
    tabBackgroundColor: AppColors.primary.withOpacity(0.12),

    curve: Curves.easeOutExpo,
    duration: const Duration(milliseconds: 450),

    textStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),

    tabs: const [
      GButton(
        icon: IconlyBold.home,
        text: 'Home',
      ),
      GButton(
        icon: IconlyBold.heart,
        text: 'Mind',
      ),
      GButton(
        icon: IconlyBold.bag_2,
        text: 'Nutrition',
      ),
      GButton(
        icon: IconlyBold.shield_done,
        text: 'Health',
      ),
        GButton(
        icon: IconlyBold.star,
        text: 'Milestones',
      )
    ],
  ),
),


    );
  }
}
