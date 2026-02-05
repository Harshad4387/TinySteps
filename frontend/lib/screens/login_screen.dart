import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api.dart';
import '../services/auth_storage.dart';
import 'dashboard/dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String role = "mother";
  String error = "";

  Future<void> login() async {
    setState(() {
      loading = true;
      error = "";
    });

    try {
      final res = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode != 200) {
        throw data["message"] ?? "Login failed";
      }

      await AuthStorage.saveAuth(data["token"], data["parent"]);

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
    final primaryColor = const Color(0xFFE56C7A);
    final bgColor = const Color(0xFFFFFBF7);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// App Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: primaryColor.withOpacity(0.15),
                    child: Icon(Icons.child_care,
                        color: primaryColor, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
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

              /// Welcome Text
              const Text(
                "Welcome Back! 👋",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sign in to continue your parenting journey",
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
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(width: 12),
                  _roleCard(
                    label: "Father",
                    icon: Icons.male,
                    selected: role == "father",
                    onTap: () => setState(() => role = "father"),
                    primaryColor: primaryColor,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// Email
              const Text("Email"),
              const SizedBox(height: 8),
              _inputField(
                controller: emailController,
                hint: "Enter your email",
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 16),

              /// Password
              const Text("Password"),
              const SizedBox(height: 8),
              _inputField(
                controller: passwordController,
                hint: "Enter your password",
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

              /// Sign In Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: loading ? null : login,
                  child: Text(
                    loading ? "Signing in..." : "Sign In",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Register
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: "Create one",
                          style: TextStyle(
                              color: Color(0xFFE56C7A),
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
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

  /// ---------- Widgets ----------

  Widget _roleCard({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
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

  Widget _inputField({
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
}
