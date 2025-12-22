class ProductModel {
  final String nameProduct;
  final double price;
  final int qty;
  final String unit;      // ⭐ THÊM MỚI
  final double total;

  ProductModel({
    required this.nameProduct,
    required this.price,
    required this.qty,
    required this.unit,    // ⭐ THÊM MỚI
    required this.total,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      nameProduct: map['nameProduct'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      qty: (map['qty'] as num?)?.toInt() ?? 0,
      unit: map['unit'] ?? '',         // ⭐ THÊM MỚI
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nameProduct': nameProduct,
      'price': price,
      'qty': qty,
      'unit': unit,        // ⭐ THÊM MỚI
      'total': total,
    };
  }
}
