import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/medicine_model.dart';
import '../../services/medicine_api.dart';
import '../../widgets/medicine_card.dart';

class MedicineSearchPage extends StatefulWidget {
  const MedicineSearchPage({super.key});

  @override
  State<MedicineSearchPage> createState() => _MedicineSearchPageState();
}

class _MedicineSearchPageState extends State<MedicineSearchPage> {
  final TextEditingController searchController = TextEditingController();
  List<Medicine> medicines = [];
  bool isLoading = false;
  Timer? debounce;

  void onSearchChanged(String value) {
    if (debounce?.isActive ?? false) debounce!.cancel();

    debounce = Timer(const Duration(milliseconds: 600), () async {
      if (value.isEmpty) {
        setState(() => medicines = []);
        return;
      }

      setState(() => isLoading = true);

      try {
        final results = await MedicineApi.searchMedicine(value);
        setState(() => medicines = results);
      } catch (_) {}

      setState(() => isLoading = false);
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Search Medicines"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔍 Floating Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Material(
              elevation: 6,
              shadowColor: Colors.black12,
              borderRadius: BorderRadius.circular(16),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Search medicines (e.g. Dolo 650)",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            searchController.clear();
                            setState(() => medicines = []);
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // 📦 Content Area
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => const _MedicineSkeleton(),
      );
    }

    if (medicines.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              "Search for medicines",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        return AnimatedSlide(
          offset: const Offset(0, 0),
          duration: Duration(milliseconds: 200 + index * 60),
          child: MedicineCard(medicine: medicines[index]),
        );
      },
    );
  }
}

/// 🦴 Skeleton Loader Card
class _MedicineSkeleton extends StatelessWidget {
  const _MedicineSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 16, width: 160, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Container(height: 12, width: double.infinity, color: Colors.grey.shade200),
          const SizedBox(height: 6),
          Container(height: 12, width: 220, color: Colors.grey.shade200),
        ],
      ),
    );
  }
}
