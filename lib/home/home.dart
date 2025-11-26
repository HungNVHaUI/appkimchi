import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghi_no/home/widgets/home_appbar.dart';
import '../create_note/all_note.dart';
import '../create_note/create_note.dart';
import '../fill/fill_controller.dart';
import '../key/key_check_screen.dart';
import '../key/key_controller.dart';
import '../key/key_screen.dart';
import '../key/license_checker.dart';
import '../theme/constants/container/header_container.dart';
import '../theme/constants/container/search_container.dart';
import '../theme/constants/sizes.dart';
import '../theme/constants/text_strings.dart';
import '../theme/constants/texts/section_heading.dart';

import 'list_note_page.dart';

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
                  padding: const EdgeInsets.only(left: TSizes.defaultSpace),
                  child: TSectionHeading(
                    title: "Danh Sách Khách",
                    showActionButton: false,
                    textColor: Colors.white,
                    onPressed: () =>
                        Get.to(() => AllNoteScreen()),
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


        ],
      ),
    );
  }
}
