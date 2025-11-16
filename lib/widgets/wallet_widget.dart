import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero_koin/controllers/theme_controller.dart';

class WalletWidget extends StatelessWidget {
  const WalletWidget({super.key, required this.title, required this.hintText});

  final String title;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => Container(
        width: 160,
        height: 160,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color:
              themeController.isDarkMode
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: themeController.borderColor.withOpacity(0.7),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        // Center everything vertically + horizontally
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Box
            Image.asset('assets/mining.png', height: 50, width: 40),

            const SizedBox(height: 6),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: themeController.textColor,
              ),
            ),

            const SizedBox(height: 4),

            // Value
            Text(
              hintText,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeController.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
