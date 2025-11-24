import 'package:cloud_firestore/cloud_firestore.dart';

import '../../create_note/model/product_model.dart';

class NoteModel {
  final String id;
  final String clientName;
  final double totalAll;
  final DateTime createdAt;
  final String phoneNumber;
   bool debt;
  final List<ProductModel> products; // thêm thuộc tính products

  NoteModel({
    required this.id,
    required this.clientName,
    this.phoneNumber = '', // default rỗng
    required this.createdAt,
    required this.totalAll,
    required this.debt, // default false
    this.products = const [], // default rỗng
  });

  // Factory constructor để ánh xạ dữ liệu từ Firestore
  factory NoteModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;

    DateTime createdDate;
    if (data['createdAt'] is Timestamp) {
      createdDate = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      createdDate = DateTime.parse(data['createdAt']);
    } else {
      createdDate = DateTime.now();
    }

    // Load danh sách products
    List<ProductModel> products = [];
    if (data['products'] != null && data['products'] is List) {
      products = (data['products'] as List)
          .map((p) => ProductModel.fromMap(p as Map<String, dynamic>))
          .toList();
    }

    return NoteModel(
      id: document.id,
      clientName: data['clientName'] ?? 'Không tên khách hàng',
      totalAll: (data['totalAll'] is int)
          ? (data['totalAll'] as int).toDouble()
          : data['totalAll'] ?? 0.0,
      createdAt: createdDate,
      debt: data['debt'] ?? false,
      products: products,
    );
  }

}