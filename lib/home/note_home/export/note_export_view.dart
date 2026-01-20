import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../purchar/purchar_controller.dart';
import '../note_detail_controller.dart';
import 'export_header.dart';
import 'package:get/get.dart';

class NoteExportView extends StatelessWidget {
  final NoteDetailController controller;

  const NoteExportView({super.key, required this.controller});

  String _formatMoney(num value) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              ExportHeader(controller: controller),

              const SizedBox(height: 28),

              /// TABLE
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.4),
                ),
                child: Column(
                  children: [
                    _tableHeader(),
                    ...controller.mutableProducts.map(_productRow).toList(),
                    _totalRow(),
                    _totalDebtRow(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// STATUS
              _statusSection(),

              const SizedBox(height: 36),

              const Center(
                child: Text(
                  "Xin chân thành cảm ơn Quý khách!",
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= ROW WRAPPER (KÍN CỘT) =================
  Widget _tableRow(List<Widget> cells, {Color? bgColor}) {
    return Container(
      color: bgColor,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: cells,
        ),
      ),
    );
  }

  /// ================= HEADER =================
  Widget _tableHeader() {
    return _tableRow(
      [
        _cell('Sản Phẩm', flex: 8, isHeader: true),
        _cell('ĐV', flex: 5, isHeader: true, align: TextAlign.center),
        _cell('SL', flex: 4, isHeader: true, align: TextAlign.center),
        _cell('Đơn giá', flex: 8, isHeader: true, align: TextAlign.right),
        _cell(
          'Thành Tiền',
          flex: 8,
          isHeader: true,
          align: TextAlign.right,
          hasRightBorder: false,
        ),
      ],
      bgColor: const Color(0xFFE5E5E5),
    );
  }

  /// ================= PRODUCT ROW =================
  Widget _productRow(dynamic product) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: _tableRow(
        [
          _cell(product['nameProduct'] ?? '', flex: 8),
          _cell(product['unit'] ?? '', flex: 5, align: TextAlign.center),
          _cell('${product['qty'] ?? 0}', flex: 4, align: TextAlign.center),
          _cell(_formatMoney(product['price'] ?? 0),
              flex: 8, align: TextAlign.right),
          _cell(
            _formatMoney(product['total'] ?? 0),
            flex: 8,
            align: TextAlign.right,
            isBold: true,
            hasRightBorder: false,
          ),
        ],
      ),
    );
  }

  /// ================= TOTAL =================
  Widget _totalRow() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F6F6),
        border: Border(top: BorderSide(color: Colors.black, width: 1.4)),
      ),
      child: _tableRow(
        [
          _cell(
            'TỔNG HOÁ ĐƠN',
            flex: 17,
            isBold: true,
            align: TextAlign.center,
          ),
          _cell(
            _formatMoney(controller.grandTotal.value),
            flex: 16,
            isBold: true,
            align: TextAlign.center,
            textColor: Colors.red[700],
            hasRightBorder: false,
          ),
        ],
      ),
    );
  }

  /// ================= CELL =================
  Widget _cell(
      String text, {
        required int flex,
        bool isHeader = false,
        bool isBold = false,
        TextAlign align = TextAlign.left,
        Color? textColor,
        bool hasRightBorder = true,
      }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: hasRightBorder
              ? Border(right: BorderSide(color: Colors.grey.shade400))
              : null,
        ),
        child: Text(
          text,
          softWrap: true,
          style: TextStyle(
            fontSize: isHeader ? 12.5 : 12,
            fontWeight: (isHeader || isBold)
                ? FontWeight.w600
                : FontWeight.normal,
            height: 1.35,
            color: textColor ?? Colors.black87,
          ),
          textAlign: align,
        ),
      ),
    );
  }


  Widget _totalDebtRow() {
    final customersController = Get.find<CustomersController>();

    final customer = customersController.getCustomerByName(
      controller.clientNameController.text,
    );

    final totalDebt = customer?.totalDebt ?? 0;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF5F5),
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: _tableRow(
        [
          _cell(
            'TỔNG KHÁCH NỢ',
            flex: 17,
            isBold: true,
            align: TextAlign.center,
          ),
          _cell(
            _formatMoney(totalDebt),
            flex: 16,
            isBold: true,
            align: TextAlign.center,
            textColor: totalDebt > 0 ? Colors.red[700] : Colors.grey,
            hasRightBorder: false,
          ),
        ],
      ),
    );
  }

  /// ================= STATUS =================
  Widget _statusSection() {
    final isDebt = controller.debtStatus.value;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: isDebt ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDebt ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDebt ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            color: isDebt ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 10),
          Text(
            isDebt ? "KHÁCH CHƯA THANH TOÁN HÓA ĐƠN NÀY" : "ĐÃ THANH TOÁN",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isDebt ? Colors.red[700] : Colors.green[700],
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
