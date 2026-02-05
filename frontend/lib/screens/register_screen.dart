import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api.dart';
import 'dashboard/dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final motherEmail = TextEditingController();
  final fatherEmail = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();

  bool loading = false;
  String role = "mother";
  String error = "";

  Future<void> register() async {
    setState(() {
      loading = true;
      error = "";
    });

    try {
      final res = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.register),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "motherName": role == "mother" ? "Mother" : null,
          "motherEmail": motherEmail.text.trim(),
          "fatherName": role == "father" ? "Father" : null,
          "fatherEmail":
              fatherEmail.text.isEmpty ? null : fatherEmail.text.trim(),
          "phoneNumber": phone.text.trim(),
          "password": password.text.trim(),
          "role": role
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode != 201) {
        throw data["message"] ?? "Registration failed";
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFE56C7A);
    const bgColor = Color(0xFFFFFBF7);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: primaryColor.withOpacity(0.15),
                    child: const Icon(Icons.child_care,
                        color: primaryColor, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("TinySteps",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text("♡ Maternal & Infant Care",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 32),

              /// Title
              const Text(
                "Create Account ✨",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Start your parenting journey with TinySteps",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 28),

              /// Role Selector
              const Text("I am a",
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),

              Row(
                children: [
                  _roleCard(
                    label: "Mother",
                    icon: Icons.female,
                    selected: role == "mother",
                    onTap: () => setState(() => role = "mother"),
                  ),
                  const SizedBox(width: 12),
                  _roleCard(
                    label: "Father",
                    icon: Icons.male,
                    selected: role == "father",
                    onTap: () => setState(() => role = "father"),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// Inputs
              _label("Mother Email *"),
              _input(
                controller: motherEmail,
                hint: "Enter mother's email",
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 16),

              _label("Father Email (optional)"),
              _input(
                controller: fatherEmail,
                hint: "Enter father's email",
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 16),

              _label("Phone Number"),
              _input(
                controller: phone,
                hint: "Enter phone number",
                icon: Icons.phone_outlined,
              ),

              const SizedBox(height: 16),

              _label("Password"),
              _input(
                controller: password,
                hint: "Create a password",
                icon: Icons.lock_outline,
                obscure: true,
              ),

              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(error,
                      style: const TextStyle(color: Colors.red)),
                ),

              const SizedBox(height: 28),

              /// CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: loading ? null : register,
                  child: Text(
                    loading ? "Creating..." : "Create Account",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              /// Footer
              const Center(
                child: Text(
                  "✧ Team Tech Titans 2.0",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------- Reusable Widgets ----------

  static Widget _label(String text) {
    return Text(text,
        style: const TextStyle(fontWeight: FontWeight.w500));
  }

  static Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static Widget _roleCard({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    const primaryColor = Color(0xFFE56C7A);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: selected
                ? primaryColor.withOpacity(0.12)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected ? primaryColor : Colors.grey.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected ? primaryColor : Colors.grey),
              const SizedBox(height: 6),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
