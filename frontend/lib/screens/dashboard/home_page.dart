import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../models/infant_models.dart';
import '../../services/infant_services.dart';
import '../../theme/colors.dart';
import '../../widgets/pastel_card.dart';

/// ================= HOME PAGE =================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          /// 🌸 HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Good Evening 🌸",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Here’s how your little one is doing today",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, size: 26),
                color: AppColors.textPrimary,
                onPressed: () {},
              ),
            ],
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),

          const SizedBox(height: 24),

          /// 👶 INFANT HERO CARD
          const _InfantHeroCard(),

          const SizedBox(height: 28),

          /// 📊 QUICK STATS (HARDCODED)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            children: const [
              _StatTile(
                "Today's Feeds",
                "6",
                Icons.restaurant_menu,
                AppColors.peachSoft,
              ),
              _StatTile(
                "Sleep Hours",
                "14h",
                Icons.bedtime_outlined,
                AppColors.lavenderSoft,
              ),
              _StatTile(
                "Weight",
                "6.2 kg",
                Icons.trending_up,
                AppColors.mintSoft,
              ),
              _StatTile(
                "Next Vaccine",
                "BCG",
                Icons.vaccines_outlined,
                AppColors.pinkSoft,
              ),
            ],
          ),

          const SizedBox(height: 32),

          /// 🔔 TODAY'S REMINDERS
          const Text(
            "Today's Reminders 🔔",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          const _TodaysRemindersSection(),
        ],
      ),
    );
  }
}

/// ================= HARDCODED REMINDERS =================
class _TodaysRemindersSection extends StatelessWidget {
  const _TodaysRemindersSection();

  static final List<Map<String, dynamic>> _reminders = [
    {
      "title": "Morning Feed",
      "description": "Milk feeding (120 ml)",
      "time": DateTime.now().copyWith(hour: 8, minute: 0),
    },
    {
      "title": "Vitamin D Drops",
      "description": "2 drops after feed",
      "time": DateTime.now().copyWith(hour: 10, minute: 30),
    },
    {
      "title": "Afternoon Nap",
      "description": "Ensure quiet environment",
      "time": DateTime.now().copyWith(hour: 13, minute: 0),
    },
    {
      "title": "Evening Feed",
      "description": "Milk feeding (120 ml)",
      "time": DateTime.now().copyWith(hour: 18, minute: 30),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _reminders.map((r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PastelCard(
            color: AppColors.peachSoft,
            child: ListTile(
              leading: const Icon(Icons.alarm_rounded),
              title: Text(
                r["title"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(r["description"]),
              trailing: Text(
                DateFormat.jm().format(r["time"]),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// ================= INFANT HERO =================
class _InfantHeroCard extends StatefulWidget {
  const _InfantHeroCard();

  @override
  State<_InfantHeroCard> createState() => _InfantHeroCardState();
}

class _InfantHeroCardState extends State<_InfantHeroCard> {
  late Future<List<Infant>> _future;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _future = InfantService.fetchMyInfants();
      _loaded = true;
    }
  }

  void _refresh() {
    setState(() {
      _future = InfantService.fetchMyInfants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FutureBuilder<List<Infant>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text(
              "Loading infant details...",
              style: TextStyle(color: Colors.white70),
            );
          }

          final infants = snapshot.data!;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: infants.isEmpty
                    ? const Text(
                        "No infant added yet",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      )
                    : _InfantInfo(infant: infants.first),
              ),
              InkWell(
                onTap: () async {
                  final added = await _openAddInfantSheet(context);
                  if (added == true) _refresh();
                },
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ================= INFANT INFO =================
class _InfantInfo extends StatelessWidget {
  final Infant infant;
  const _InfantInfo({required this.infant});

  @override
  Widget build(BuildContext context) {
    final ageMonths =
        DateTime.now().difference(infant.dateOfBirth).inDays ~/ 30;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          infant.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "$ageMonths months • Healthy ❤️",
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

/// ================= ADD INFANT SHEET =================
Future<bool?> _openAddInfantSheet(BuildContext context) {
  final nameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
          TextField(controller: dobCtrl, decoration: const InputDecoration(labelText: "DOB")),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              await InfantService.addInfant({
                "name": nameCtrl.text,
                "dateOfBirth": dobCtrl.text,
              });
              Navigator.pop(context, true);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    ),
  );
}

/// ================= STAT TILE =================
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return PastelCard(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label),
        ],
      ),
    );
  }
}
