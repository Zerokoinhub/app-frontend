
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:zero_koin/controllers/theme_controller.dart';

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  // Controller for theme (you can adjust based on your actual theme controller)
    final ThemeController themeController = Get.find<ThemeController>();
     // Replace with your actual theme controller
  
  // Track which FAQ is expanded
  List<bool> isExpanded = [false, false, false,false];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
     // Increased height to accommodate answers
        width: 330,
        decoration: BoxDecoration(
          color: themeController.cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20,
            left: 25,
            right: 25,bottom: 25
          ),
          child: Column(  mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 235),
                child: Text(
                  "FAQ",
                  style: TextStyle(
                    fontFamily: "Coolvetica",
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: themeController.textColor,
                  ),
                ),
              ),
              SizedBox(height: 10),
              
              // FAQ Item 1
              _buildFAQItem(
                index: 0,
                question: "How can i refer a friend?",
                answer: "You can refer a friend by sharing your unique Zero Koin referral link or code with them.\n\nWhen your friend signs up using your link and completes the required steps, the referral will be counted as successful.",
              ),
              
              SizedBox(height: 8),
                _buildFAQItem(
                index: 1,
                question: "How many friends i refer and\n win ZRK? ",
                answer: "You can refer unlimited friends. The more friends you successfully refer, the more ZRK rewards you can earn",
              ),SizedBox(height: 8),
              // FAQ Item 2
              _buildFAQItem(
                index: 2,
                question: "What is successful referal?",
                answer: "✅ Your friend signs up using your referral link\n\n✅ The referral is a first-time (fresh) user of the app\n\n✅ The user completes 4 sessions within the first 24 hours\n\nOnce all these conditions are met, your ZRK reward will be unlocked 🎉",
              ),
              
              SizedBox(height: 8),
              
              // FAQ Item 3
              _buildFAQItem(
                index: 3,
                question: "Can i refer anybody and receive the normal rewards?",
                answer: "✅ Yes\n\nYou can refer any real user, such as friends or family members.\n\nAs long as they complete the required steps, you will receive the standard referral rewards.",
              ),
              
              // FAQ Item 4 (Placeholder - will be added later)
              SizedBox(height: 8),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required int index,
    required String question,
    required String answer,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Row (clickable)
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded[index] = !isExpanded[index];
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Image.asset(
                  "assets/bullet-point 1.png",
                  color: themeController.isDarkMode ? Colors.white : Colors.black,
                  height: 12,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontFamily: "Poppins-regular",
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: themeController.textColor,
                  ),
                ),
              ),
              // Expand/collapse icon
              Icon(
                isExpanded[index] ? Icons.expand_less : Icons.expand_more,
                color: themeController.isDarkMode ? Colors.white : Colors.black,
                size: 20,
              ),
            ],
          ),
        ),
        
        // Answer Section (appears when expanded)
        if (isExpanded[index])
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 10, right: 10),
            child: Text(
              answer,
              style: TextStyle(
                fontFamily: "Poppins-regular",
                fontSize: 14,
                color: themeController.textColor.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
      ],
    );
  }
}

// Placeholder ThemeController class - replace with your actual theme controller

