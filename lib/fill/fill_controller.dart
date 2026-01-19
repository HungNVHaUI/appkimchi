import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../create_note/model/note_model.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
class FillController extends GetxController {
  /// ------------------------------
  /// 🔹 Biến Observable cho bộ lọc
  /// ------------------------------
  final Rxn<int> selectedMonth = Rxn<int>();
  final Rxn<int> selectedYear = Rxn<int>();
  final RxString searchClient = ''.obs;
  var showCheckbox = false.obs;

  /// Trạng thái loading
  var isLoading = true.obs;

  /// Map lưu trạng thái checkbox của từng ghi chú (id → bool)
  var checkedMap = <String, bool>{}.obs;

  /// Tổng giá trị các ghi chú đã chọn
  var totalSelected = 0.0.obs;

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
      isLoading.value = true;

      final list =
      snapshot.docs.map((doc) => NoteModel.fromSnapshot(doc)).toList();

      allNotes.value = list;

      /// Cập nhật tháng/năm có sẵn
      _updateAvailableFilters(list);

      isLoading.value = false;
    });

    /// ------------------------------
    /// 🔹 Tự động tính tổng khi filter hoặc checkbox thay đổi
    /// ------------------------------
    ever(selectedMonth, (_) => calculateTotal());
    ever(selectedYear, (_) => calculateTotal());
    debounce(searchClient, (_) => calculateTotal(), time: const Duration(milliseconds: 300));
    ever(checkedMap, (_) => calculateTotal());
  }

  /// ------------------------------
  /// 🔹 Cập nhật tháng & năm có sẵn
  /// ------------------------------
  void _updateAvailableFilters(List<NoteModel> notes) {
    if (notes.isNotEmpty) {
      availableMonths.value = notes.map((n) => n.createdAt.month).toSet().toList()..sort();
      availableYears.value = notes.map((n) => n.createdAt.year).toSet().toList()..sort((a, b) => b.compareTo(a));
    } else {
      availableMonths.clear();
      availableYears.clear();
    }

    // Tính tổng sau khi filter thay đổi
    calculateTotal();
  }

  /// ------------------------------
  /// 🔹 Toggle checkbox
  /// ------------------------------
  void toggleCheck(NoteModel note) {
    bool current = checkedMap[note.id] ?? false;
    checkedMap[note.id] = !current;
    // calculateTotal(); // không cần gọi trực tiếp nữa, ever(checkedMap) đã xử lý
  }
  void resetFilters() {
    selectedMonth.value = null;
    selectedYear.value = null;
    searchClient.value = "";
    checkedMap.clear();
    showCheckbox.value = false;

    // gọi lại tính tổng để update UI
    calculateTotal();
  }


  void toggleCheckById(String noteId) {
    checkedMap[noteId] = !(checkedMap[noteId] ?? false);
    // calculateTotal(); // đã có ever
  }

  void enableCheckbox() => showCheckbox.value = true;

  void disableCheckbox() {
    showCheckbox.value = false;
    checkedMap.clear(); // bỏ chọn luôn
  }

  /// ------------------------------
  /// 🔹 Tính tổng
  /// ------------------------------
  void calculateTotal() {
    double total = 0.0;

    // Danh sách note đã chọn
    final selectedNotes =
    filteredNotes.where((note) => checkedMap[note.id] == true).toList();

    if (selectedNotes.isNotEmpty) {
      total = selectedNotes.fold(0.0, (sum, note) => sum + note.totalAll);
    } else {
      total = filteredNotes.fold(0.0, (sum, note) => sum + note.totalAll);
    }

    totalSelected.value = total;
  }

  /// ------------------------------
  /// 🔹 Lọc dữ liệu
  /// ------------------------------
  List<NoteModel> get filteredNotes {
    final filtered = allNotes.where((note) {
      final monthOK =
          selectedMonth.value == null || note.createdAt.month == selectedMonth.value;
      final yearOK =
          selectedYear.value == null || note.createdAt.year == selectedYear.value;
      final searchOK = searchClient.value.isEmpty ||
          note.clientName.toLowerCase().contains(searchClient.value.toLowerCase());

      return monthOK && yearOK && searchOK;
    }).toList();

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  double get totalAllFiltered =>
      filteredNotes.fold(0.0, (sum, item) => sum + item.totalAll);

  String get totalAllFilteredFormatted {
    final total = totalAllFiltered;
    return NumberFormat.decimalPattern('vi_VN').format(total);
  }

  /// ------------------------------x`xxxxxxxxx`
  /// 🔹 Clear filter
  /// ------------------------------
  void clearFilters() {
    selectedMonth.value = null;
    selectedYear.value = null;
    searchClient.value = "";
  }
}
