import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero_koin/controllers/theme_controller.dart';

class WalletWidget extends StatefulWidget {
  const WalletWidget({super.key, required this.title, required this.hintText});

  final String title;
  final String hintText;

  @override
  State<WalletWidget> createState() => _WalletWidgetState();
}

class _WalletWidgetState extends State<WalletWidget> {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();

    _focusNode.addListener(() {
      // Rebuild so hintText can appear/disappear on focus changes
      if (mounted) setState(() {});
    });

    _controller.addListener(() {
      // Rebuild when text changes so hintText hides when user types
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final ThemeController themeController = Get.find<ThemeController>();

    // Show hint only when the field is not focused and empty
    final showHint = !_focusNode.hasFocus && _controller.text.isEmpty;

    return Obx(
      () => Container(
        width: screenWidth,
        decoration: BoxDecoration(
          border: Border.all(color: themeController.borderColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: themeController.textColor,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: TextStyle(color: themeController.textColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor:
                        themeController.isDarkMode
                            ? Colors.grey[800]
                            : const Color(0xFFEFE5E5),
                    hintText: showHint ? widget.hintText : null,
                    hintStyle: TextStyle(color: themeController.subtitleColor),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/mining.png',
                        height: 20,
                        width: 20,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: themeController.borderColor,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: themeController.borderColor,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
