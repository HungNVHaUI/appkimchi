import 'package:cloud_firestore/cloud_firestore.dart';
import '../../create_note/model/product_model.dart';

class NoteModel {
  final String id;
  final String clientName;
  final double totalAll;
  final DateTime createdAt;
  final String phoneNumber;
  final bool debt;
  final List<ProductModel> products;

  NoteModel({
    required this.id,
    required this.clientName,
    this.phoneNumber = '',
    required this.createdAt,
    required this.totalAll,
    this.debt = false,
    this.products = const [],
  });

  factory NoteModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    // Parse createdAt
    DateTime createdDate;
    final createdAtValue = data['createdAt'];
    if (createdAtValue is Timestamp) {
      createdDate = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      createdDate = DateTime.tryParse(createdAtValue) ?? DateTime.now();
    } else {
      createdDate = DateTime.now();
    }

    // Parse totalAll
    double total;
    if (data['totalAll'] is int) {
      total = (data['totalAll'] as int).toDouble();
    } else if (data['totalAll'] is double) {
      total = data['totalAll'] as double;
    } else {
      total = 0.0;
    }

    // Parse products
    List<ProductModel> productsList = [];
    if (data['products'] != null && data['products'] is List) {
      productsList = (data['products'] as List)
          .whereType<Map<String, dynamic>>()
          .map((p) => ProductModel.fromMap(p))
          .toList();
    }

    return NoteModel(
      id: doc.id,
      clientName: data['clientName'] ?? 'Không tên khách hàng',
      totalAll: total,
      createdAt: createdDate,
      phoneNumber: data['phoneNumber'] ?? '',
      debt: data['debt'] ?? false,
      products: productsList,
    );
  }
}
