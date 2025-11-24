class ProductModel {
  final String nameProduct;
  final double price;
  final int qty;
  final double total;

  ProductModel({
    required this.nameProduct,
    required this.price,
    required this.qty,
    required this.total,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      nameProduct: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      qty: map['qty'] ?? 0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
