class ProductDetails {
  final String name;
  final String description;
  final String category;
  final Map<String, String> specifications;

  ProductDetails({
    required this.name,
    required this.description,
    required this.category,
    required this.specifications,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) => ProductDetails(
        name: json['name'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        specifications: Map<String, String>.from(json['specifications'] as Map),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'category': category,
        'specifications': specifications,
      };

  ProductDetails copyWith({
    String? name,
    String? description,
    String? category,
    Map<String, String>? specifications,
  }) =>
      ProductDetails(
        name: name ?? this.name,
        description: description ?? this.description,
        category: category ?? this.category,
        specifications: specifications ?? this.specifications,
      );
}
