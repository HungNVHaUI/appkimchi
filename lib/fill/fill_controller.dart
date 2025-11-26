import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../home/model/note_model.dart';

class FillController extends GetxController {
  /// ------------------------------
  /// 🔹 Biến Observable cho bộ lọc
  /// ------------------------------
  final Rxn<int> selectedMonth = Rxn<int>();
  final Rxn<int> selectedYear = Rxn<int>();
  final RxString searchClient = ''.obs;

  /// Trạng thái loading
  var isLoading = true.obs;

  /// ------------------------------
  /// 🔹 Stream Firestore
  /// ------------------------------
  final Stream<QuerySnapshot<Map<String, dynamic>>> notesStream =
  FirebaseFirestore.instance
      .collection('notes')
      .orderBy('createdAt', descending: true)
      .snapshots();

  /// Danh sách ghi chú gốc
  final RxList<NoteModel> allNotes = RxList<NoteModel>([]);

  /// Danh sách tháng/năm để filter
  final RxList<int> availableMonths = RxList<int>([]);
  final RxList<int> availableYears = RxList<int>([]);

  @override
  void onInit() {
    super.onInit();

    /// Lắng nghe Firestore
    notesStream.listen((snapshot) {
      isLoading.value = true; // bắt đầu loading

      final list = snapshot.docs
          .map((doc) => NoteModel.fromSnapshot(doc))
          .toList();

      allNotes.value = list;

      /// Cập nhật tháng/năm có sẵn
      _updateAvailableFilters(list);

      isLoading.value = false; // load xong
    });
  }

  /// ------------------------------
  /// 🔹 Cập nhật tháng & năm có sẵn
  /// ------------------------------
  void _updateAvailableFilters(List<NoteModel> notes) {
    if (notes.isNotEmpty) {
      availableMonths.value =
      notes.map((n) => n.createdAt.month).toSet().toList()..sort();

      availableYears.value =
      notes.map((n) => n.createdAt.year).toSet().toList()
        ..sort((a, b) => b.compareTo(a)); // năm mới nhất trước
    } else {
      availableMonths.clear();
      availableYears.clear();
    }
  }

  /// ------------------------------
  /// 🔹 Lọc dữ liệu
  /// ------------------------------
  List<NoteModel> get filteredNotes {
    final filtered = allNotes.where((note) {
      final monthOK = selectedMonth.value == null ||
          note.createdAt.month == selectedMonth.value;

      final yearOK = selectedYear.value == null ||
          note.createdAt.year == selectedYear.value;

      final searchOK = searchClient.value.isEmpty ||
          note.clientName
              .toLowerCase()
              .contains(searchClient.value.toLowerCase());

      return monthOK && yearOK && searchOK;
    }).toList();

    /// Sắp xếp theo thời gian (mới nhất trước)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  /// ------------------------------
  /// 🔹 Clear filter
  /// ------------------------------
  void clearFilters() {
    selectedMonth.value = null;
    selectedYear.value = null;
    searchClient.value = "";
  }
}
