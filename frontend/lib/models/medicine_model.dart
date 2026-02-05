class Medicine {
  final String name;
  final String slug;
  final String image;
  final double? price;

  Medicine({
    required this.name,
    required this.slug,
    required this.image,
    this.price,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'] ?? '',
      price: json['price'] != null
          ? (json['price'] as num).toDouble()
          : null,
    );
  }
}
