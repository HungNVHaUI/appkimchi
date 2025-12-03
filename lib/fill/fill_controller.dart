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
    ever(searchClient, (_) => calculateTotal());
    ever(checkedMap, (_) => calculateTotal());
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
        ..sort((a, b) => b.compareTo(a));
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
          note.clientName
              .toLowerCase()
              .contains(searchClient.value.toLowerCase());

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
  /*Future<String?> exportToExcel({bool onlySelected = false}) async {
    try {
      // 1. Chọn danh sách note cần xuất (Giữ nguyên)
      List<NoteModel> notesToExport;
      if (onlySelected) {
        notesToExport =
            filteredNotes.where((note) => checkedMap[note.id] == true).toList();
      } else {
        notesToExport = filteredNotes;
      }

      if (notesToExport.isEmpty) return null;

      // 2. Tạo Excel (Giữ nguyên)
      var excel = Excel.createExcel();
      Sheet sheet = excel['Sheet1'];

      final dateFormat = DateFormat('dd/MM/yyyy');
      final numberFormatter = NumberFormat.decimalPattern('vi_VN');

      // 3. Thêm header
      sheet.appendRow([
        TextCellValue('Ngày tạo'),
        TextCellValue('Tên khách hàng'),
        TextCellValue('Số điện thoại'),
        TextCellValue('Tổng tiền Giao dịch'),
        TextCellValue('Trạng thái nợ'),

        TextCellValue('Tên Sản phẩm'),
        TextCellValue('Số lượng'),
        TextCellValue('Giá đơn vị'),
        TextCellValue('Thành tiền Sản phẩm'),
      ]);

      // ============================
      // 🔥 API Google Apps Script
      const String API_URL = "https://script.google.com/macros/s/AKfycby7rR29ukvzqfE1uTM6CxU2lk_sCg2DWqU95EpazscZ8sEB0_la8Bzh60cbbPo4SNbm/exec";
      // ============================

      // 4. Lặp từng note + sản phẩm
      for (var note in notesToExport) {
        final debtStatus = note.debt ? 'CÓ NỢ' : 'Không nợ';
        final formattedTotalAll = numberFormatter.format(note.totalAll);

        if (note.products.isEmpty) {
          // Ghi vào Excel
          sheet.appendRow([
            TextCellValue(dateFormat.format(note.createdAt)),
            TextCellValue(note.clientName),
            TextCellValue(note.phoneNumber),
            TextCellValue(formattedTotalAll),
            TextCellValue(debtStatus),

            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
          ]);

          // Gửi API Google Sheet
          await http.post(
            Uri.parse(API_URL),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "date": dateFormat.format(note.createdAt),
              "client": note.clientName,
              "phone": note.phoneNumber,
              "total": formattedTotalAll,
              "debt": debtStatus,

              "product": "",
              "qty": "",
              "price": "",
              "totalProduct": "",
            }),
          );

          continue;
        }

        // Nếu có sản phẩm → lặp từng sản phẩm
        for (var product in note.products) {
          final formattedPrice = numberFormatter.format(product.price);
          final formattedTotal = numberFormatter.format(product.total);

          // Ghi Excel
          sheet.appendRow([
            TextCellValue(dateFormat.format(note.createdAt)),
            TextCellValue(note.clientName),
            TextCellValue(note.phoneNumber),
            TextCellValue(formattedTotalAll),
            TextCellValue(debtStatus),

            TextCellValue(product.nameProduct),
            TextCellValue(product.qty.toString()),
            TextCellValue(formattedPrice),
            TextCellValue(formattedTotal),
          ]);

          // Gửi API Google Sheet
          await http.post(
            Uri.parse(API_URL),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "date": dateFormat.format(note.createdAt),
              "client": note.clientName,
              "phone": note.phoneNumber,
              "total": formattedTotalAll,
              "debt": debtStatus,

              "product": product.nameProduct,
              "qty": product.qty,
              "price": formattedPrice,
              "totalProduct": formattedTotal,
            }),
          );
        }
      }

      // 5. Lưu file Excel (Giữ nguyên)
      Directory directory;
      if (Platform.isAndroid || Platform.isIOS) {
        directory = (await getExternalStorageDirectory())!;
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final path = '${directory.path}/Notes_$timestamp.xlsx';

      final excelBytes = excel.encode();
      if (excelBytes == null) return null;

      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excelBytes);

      return path;
    } catch (e) {
      print('Export Excel Error: $e');
      return null;
    }
  }*/
  Future<void> testSendToGoogleSheet() async {
    const String API_URL = "https://script.google.com/macros/s/YOUR_SCRIPT_ID/exec";

    final Map<String, dynamic> testData = {
      "date": "27/11/2025",
      "client": "Khách Test",
      "phone": "0123456789",
      "total": "1,000,000",
      "debt": "Không nợ",
      "products": [
        {"name": "SP Test", "qty": 1, "price": 1000000, "totalProduct": 1000000}
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(API_URL),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(testData),
      );

      if (response.statusCode == 200) {
        print("API response: ${response.body}");
      } else {
        print("Failed: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Error sending to Google Sheet: $e");
    }
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
