import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ghi_no/purchar/purchar_controller.dart';
import 'package:ghi_no/theme/constants/colors.dart';
import 'package:ghi_no/theme/constants/sizes.dart';
import 'package:ghi_no/theme/helpers/helper_functions.dart';
import 'customer_detail_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class CustomerListScreen extends StatelessWidget {
  final CustomersController controller = Get.put(CustomersController());

  CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    Future<void> _callPhone(String phone) async {
      final uri = Uri(scheme: 'tel', path: phone);
      print('Attempting to launch URI: ${uri.toString()}');
      // 1. Kiểm tra support
      if (!await canLaunchUrl(uri)) {
        ScaffoldMessenger.of(context).showSnackBar(
          // Thay đổi thông báo này để chắc chắn bạn thấy nó
          const SnackBar(content: Text("LỖI KIỂM TRA HỖ TRỢ: URI tel:// bị từ chối")),
        );
        return;
      }

      // 2. Kiểm tra quyền CALL_PHONE
      final status = await Permission.phone.status;
      if (!status.isGranted) {
        final result = await Permission.phone.request();

        if (!result.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bạn chưa cấp quyền Gọi điện")),
          );
          return;
        }
      }

      // 3. GỌI ĐIỆN (ACTION_CALL)
      try {
        await launchUrl(uri);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không gọi được: $e")),
        );
      }

    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Danh sách Khách hàng',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      // Dùng Obx vì controller có isLoading + customers (RxList)
      body: Obx(() {
        // Loading state từ controller
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Lấy danh sách từ controller (đã typed là List<CustomerInfo>)
        final customers = controller.customers;

        if (customers.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.user_octagon, size: 60),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  'Hiện không có khách hàng nào.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          itemCount: customers.length,
          separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
          itemBuilder: (context, index) {
            final c = customers[index];

            final bool hasDebt = c.totalDebt > 0;
            final Color debtColor = hasDebt ? TColors.warning : TColors.primary;
            final Color cardColor = dark ? TColors.darkContainer : TColors.white;

            // tổng tạm ứng (nếu bạn không có field totalPayments trong model)
            final num totalPayments = c.payments.fold(0, (s, p) => s + (p.amount ?? 0));

            return InkWell(
              onTap: () => Get.to(() => CustomerDetailPage(customer: c)),
              borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
              child: Container(
                padding: const EdgeInsets.all(TSizes.md),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
                  border: Border.all(
                    color: dark ? TColors.light : TColors.dark,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [

                    // CỘT TRÁI — Tên + SĐT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Tên khách
                          Text(
                            c.name,
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: debtColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: TSizes.xs),

                          // Danh sách SĐT
                          if (c.phoneNumbers.isNotEmpty)
                            Wrap(
                              spacing: TSizes.sm,
                              runSpacing: TSizes.xs,
                              children: c.phoneNumbers.map((p) {
                                return GestureDetector(
                                  onTap: () => _callPhone(p),
                                  child: Chip(
                                    label: Text(
                                      p,
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                    avatar: const Icon(Iconsax.call, size: 16),
                                    backgroundColor: dark ? TColors.darkGrey : TColors.softGrey,
                                    labelPadding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),

                    // CỘT PHẢI — NỢ + Tạm ứng
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Tổng nợ
                        Text(
                          controller.formatNumber(c.totalDebt),
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                            fontWeight: FontWeight.w800,
                            color: debtColor,
                          ),
                        ),
                        const SizedBox(height: TSizes.sm),

                        // Tổng tạm ứng
                        _buildTransactionInfo(
                          icon: Iconsax.wallet_3,
                          label: 'Tạm ứng: ${controller.formatNumber(totalPayments)}',
                          context: context,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // --- Widget nhỏ hiển thị giao dịch ---
  Widget _buildTransactionInfo({
    required IconData icon,
    required String label,
    required BuildContext context,
  }) {
    final bool dark = THelperFunctions.isDarkMode(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: TSizes.iconSm,
          color: dark ? TColors.light : TColors.dark, // màu theo theme
        ),
        const SizedBox(width: TSizes.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: dark ? TColors.light : TColors.dark, // màu chữ theo theme
          ),
        ),
      ],
    );

  }
}
