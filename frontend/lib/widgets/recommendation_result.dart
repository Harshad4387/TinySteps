import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendationResult extends StatelessWidget {
  final Map<String, dynamic> data;

  const RecommendationResult(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    final products = data["products"] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ML Recommended Product:",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          data["ml_recommendation"],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),
        Text(
          "Available Products",
          style: Theme.of(context).textTheme.titleMedium,
        ),

        const SizedBox(height: 8),
        ...products.map((p) => GestureDetector(
              onTap: p["link"] != null ? () => _launchURL(p["link"]) : null,
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(p["name"]),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p["description"]),
                      if (p["link"] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Tap to view product",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₹${p["price"]}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}
