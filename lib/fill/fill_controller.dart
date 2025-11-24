import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../home/model/note_model.dart';

class FillController extends GetxController {
  // Biến Observable cho bộ lọc
  final Rxn<int> selectedMonth = Rxn<int>(null);
  final Rxn<int> selectedYear = Rxn<int>(null);
  final RxString searchClient = ''.obs; // 🔹 Biến lọc theo tên khách hàng

  // Stream để lấy tất cả dữ liệu gốc từ Firestore
  final Stream<QuerySnapshot<Map<String, dynamic>>> notesStream =
  FirebaseFirestore.instance
      .collection('notes')
      .orderBy('createdAt', descending: true)
      .snapshots();

  // Danh sách ghi chú gốc (đã được chuyển đổi)
  final RxList<NoteModel> allNotes = RxList<NoteModel>([]);

  // Danh sách tháng và năm có sẵn (chỉ tính 1 lần khi allNotes thay đổi)
  final RxList<int> availableMonths = RxList<int>([]);
  final RxList<int> availableYears = RxList<int>([]);

  @override
  void onInit() {
    super.onInit();
    // Lắng nghe sự thay đổi của stream và cập nhật allNotes
    notesStream.listen((snapshot) {
      allNotes.value = snapshot.docs.map((doc) => NoteModel.fromSnapshot(doc)).toList();
      _updateAvailableFilters(allNotes.value);
    });
  }

  // Hàm cập nhật danh sách tháng và năm có sẵn
  void _updateAvailableFilters(List<NoteModel> notes) {
    if (notes.isNotEmpty) {
      availableMonths.value = notes.map((n) => n.createdAt.month).toSet().toList()..sort();
      availableYears.value = notes.map((n) => n.createdAt.year).toSet().toList()..sort((a, b) => b.compareTo(a));
    } else {
      availableMonths.clear();
      availableYears.clear();
    }
  }

  // 🔹 Danh sách ghi chú đã được lọc (thêm lọc theo tên)
  List<NoteModel> get filteredNotes {
    return allNotes.where((note) {
      bool monthMatch = selectedMonth.value == null || note.createdAt.month == selectedMonth.value;
      bool yearMatch = selectedYear.value == null || note.createdAt.year == selectedYear.value;

      // Nếu searchClient trống thì bỏ qua, nếu có thì kiểm tra
      bool nameMatch = searchClient.value.isEmpty ||
          note.clientName.toLowerCase().contains(searchClient.value.toLowerCase());

      return monthMatch && yearMatch && nameMatch;
    }).toList();
  }
}
