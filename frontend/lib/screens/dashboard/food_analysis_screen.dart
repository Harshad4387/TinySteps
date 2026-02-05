import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/services_2/food_analysis_service.dart';
import 'package:image_picker/image_picker.dart';

class FoodAnalysisScreen extends StatefulWidget {
  const FoodAnalysisScreen({super.key});

  @override
  State<FoodAnalysisScreen> createState() => _FoodAnalysisScreenState();
}

class _FoodAnalysisScreenState extends State<FoodAnalysisScreen> {
  File? _image;
  Map<String, dynamic>? _analysis;
  bool _loading = false;

  Future<void> _selectImage(ImageSource source) async {
    final image = await FoodAnalysisService.pickImage(source);
    if (image != null) {
      setState(() {
        _image = image;
        _analysis = null;
      });
    }
  }

  Future<void> _analyzeFood() async {
    if (_image == null) return;

    setState(() => _loading = true);

    try {
      final response =
          await FoodAnalysisService.analyzeFood(_image!);
      setState(() {
        _analysis = response['analysis'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pregnancy Food Analyzer"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image Preview
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: _image == null
                  ? const Center(child: Text("Select food image"))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    ),
            ),

            const SizedBox(height: 16),

            // Camera & Gallery Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _selectImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _selectImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: const Text("Gallery"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Analyze Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _analyzeFood,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Analyze Food"),
              ),
            ),

            const SizedBox(height: 20),

            // Result
            if (_analysis != null) _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _analysis!['foodIdentified'],
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Text(
              "Pregnancy Safe: ${_analysis!['pregnancySafety']['status']}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _analysis!['riskLevel'] == "Medium"
                    ? Colors.orange
                    : Colors.green,
              ),
            ),

            const SizedBox(height: 10),
            const Text("Health Benefits",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...(_analysis!['healthBenefits'] as List)
                .map((e) => Text("• $e")),

            const SizedBox(height: 10),
            const Text("Potential Risks",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...(_analysis!['potentialRisks'] as List)
                .map((e) => Text("• $e")),

            const SizedBox(height: 10),
            const Text("Healthier Alternatives",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...(_analysis!['healthierAlternatives'] as List)
                .map((e) => Text("• $e")),
          ],
        ),
      ),
    );
  }
}