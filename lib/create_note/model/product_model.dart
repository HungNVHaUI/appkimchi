class ProductModel {
  final String nameProduct;
  final double price;
  final double qty; // ⭐ SỬA TỪ int SANG double
  final String unit;
  final double total;

  ProductModel({
    required this.nameProduct,
    required this.price,
    required this.qty,
    required this.unit,
    required this.total,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      nameProduct: map['nameProduct'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      // ⭐ SỬA: Dùng .toDouble() thay vì .toInt()
      qty: (map['qty'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nameProduct': nameProduct,
      'price': price,
      'qty': qty, // Giờ là double nên Firebase sẽ lưu được 2.5
      'unit': unit,
      'total': total,
    };
  }
}