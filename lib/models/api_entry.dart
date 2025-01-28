class ApiEntry {
  final String username;
  final String email;
  final int userId;
  final bool isActive;
  final String registrationDate;

  // Additional data fields
  final String stringValue;
  final int integerValue;
  final double floatValue;
  final bool booleanValue;
  final List<int> arrayValue;
  final Map<String, dynamic> nestedObject;
  final List<Product> products;

  ApiEntry({
    required this.username,
    required this.email,
    required this.userId,
    required this.isActive,
    required this.registrationDate,
    required this.stringValue,
    required this.integerValue,
    required this.floatValue,
    required this.booleanValue,
    required this.arrayValue,
    required this.nestedObject,
    required this.products,
  });

  factory ApiEntry.fromJson(Map<String, dynamic> json) {
    return ApiEntry(
      // User data
      username: json['user']['username'] ?? '',
      email: json['user']['email'] ?? '',
      userId: json['user']['id'] ?? 0,
      isActive: json['user']['is_active'] ?? false,
      registrationDate: json['user']['registration_date'] ?? '',

      // Other data fields
      stringValue: json['string_value'] ?? '',
      integerValue: json['integer_value'] ?? 0,
      floatValue: json['float_value'] ?? 0.0,
      booleanValue: json['boolean_value'] ?? false,
      arrayValue: List<int>.from(json['array_value'] ?? []),
      nestedObject: json['nested_object'] ?? {},
      products: (json['products'] as List?)
              ?.map((p) => Product.fromJson(p))
              .toList() ??
          [],
    );
  }
}

class Product {
  final int productId;
  final String name;
  final double price;
  final bool inStock;
  final int percent;

  Product({
    required this.productId,
    required this.name,
    required this.price,
    required this.inStock,
    required this.percent,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] ?? 0.0,
      inStock: json['in_stock'] ?? false,
      percent: json['percent'] ?? 0,
    );
  }
}
