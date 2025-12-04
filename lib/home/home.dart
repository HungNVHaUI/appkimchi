import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghi_no/home/widgets/home_appbar.dart';
import '../fill/fill_controller.dart';
import '../theme/constants/colors.dart';
import '../theme/constants/container/header_container.dart';
import '../theme/constants/container/search_container.dart';
import '../theme/constants/sizes.dart';
import 'package:intl/intl.dart';
import 'note_home/note_list_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final controller = Get.put(FillController());
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          /// Header KHÔNG cuộn
          THeaderContainer(
            child: Column(
              children: [
                const THomeAppBar(),
                const SizedBox(height: TSizes.spaceBtwSections),
                TSearchContainer(
                  text: "Tìm khách hàng",
                  showBorder: false,
                  onChanged: (value) => controller.searchClient.value = value,
                ),

                const SizedBox(height: TSizes.spaceBtwSections),

                Padding(
                  padding: EdgeInsets.only(
                      left: TSizes.spaceBtwItems, right: TSizes.spaceBtwItems),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text("Danh Sách Khách",
                            style:
                            Theme.of(context).textTheme.titleSmall!.apply(
                              color: TColors.white,
                            )),
                      ),
                      Obx(() => Text(
                        "Tổng: ${NumberFormat.currency(locale: 'vi_VN', symbol: '').format(controller.totalSelected.value)}",
                        style: Theme.of(context).textTheme.titleMedium!.apply(color: TColors.white),
                      )),
                    ],
                  ),
                ),

                const SizedBox(height: TSizes.spaceBtwSections),

              ],
            ),
          ),


          /// ---------------------------
          /// LIST CUỘN ĐỘC LẬP
          /// ---------------------------
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: TSizes.defaultSpace,
                right: TSizes.defaultSpace,
                bottom: TSizes.defaultSpace,
                top: 0,
              ),
              /// Truyền tháng năm xuống ListNotesWidget
              child: ListNotesPage(),

            ),
          ),
          /*ElevatedButton(
            onPressed: () async {
              // Hiển thị thông báo đang xử lý (tùy chọn)
              Get.snackbar(
                  'Đang xử lý...',
                  'Vui lòng chờ trong giây lát.',
                  snackPosition: SnackPosition.BOTTOM
              );

              // Gọi hàm exportToExcel từ Controller.
              // Nếu bạn muốn xuất file đã lọc (như trong footer), hãy truyền `onlySelected: false`
              // Nếu muốn xuất file theo checkbox, hãy truyền `onlySelected: true`
              final path = await controller.exportToExcel(onlySelected: false);

              // Xử lý kết quả trả về
              if (path != null) {
                Get.snackbar(
                  'Xuất Excel Thành công!',
                  'File đã lưu tại: $path',
                  icon: const Icon(Icons.file_download_done),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
                // Bạn có thể thêm logic mở file Excel tại đây.
              } else {
                Get.snackbar(
                  'Lỗi hoặc Không có dữ liệu',
                  'Không thể xuất file hoặc danh sách ghi chú rỗng.',
                  icon: const Icon(Icons.error_outline),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Xuất Excel'), // Thay thế `child` bằng Widget thật
          )*/



        ],
      ),
    );
  }
}
