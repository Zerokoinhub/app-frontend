import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero_koin/controllers/theme_controller.dart';
import 'package:zero_koin/widgets/app_bar_container.dart';
import 'package:zero_koin/widgets/guide_text.dart';
import 'package:zero_koin/widgets/my_drawer.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:zero_koin/view/home_screen.dart';

import 'package:flutter_svg/flutter_svg.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    return Scaffold(
      drawer: MyDrawer(),
      body: Stack(
        children: [
          Image.asset(
            'assets/Background.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Column(
            children: [
              AppBarContainer(color: Colors.black.withValues(alpha: 0.6), showTotalPosition: false),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Image(
                            image: AssetImage("assets/arrow_back.png"),
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Guide",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Obx(
                  () => Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          themeController.isDarkMode
                              ? Colors.black.withValues(alpha: 0.8)
                              : Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/Info Icon.svg",
                                  width: 25,
                                  height: 25,
                                  colorFilter: ColorFilter.mode(
                                    themeController.isDarkMode ? Colors.white : Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "ZeroKoin Guide",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 25,
                                    color: themeController.textColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Text(
                              "What is ZeroKoin?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: themeController.textColor,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              "Redefining crypto with tokenized learning, smart tools & real-world rewards. Built for scale. Every revolution begins from Zero.",
                              style: TextStyle(
                                fontSize: 18,
                                color: themeController.subtitleColor,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Start Mining - Earn 30 ZeroKoins Every 6 Hours",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 25,
                                color: themeController.textColor,
                              ),
                            ),
                            SizedBox(height: 10),
                            Column(
                              children: [
                                GuideText(
                                  title: "Sign in with your Google account.",
                                ),
                                GuideText(
                                  title: "New users get 1 free Energy.",
                                ),
                                GuideText(
                                  title:
                                      "You can mine up to 4 times a day, with 1 session every 6 hours",
                                ),
                                GuideText(
                                  title: "Tap the \"GET KOIN\" button to earn 30 ZeroKoins per session",
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Image.asset("assets/ff1.png"),
                            SizedBox(height: 20),
                            Text(
                              "More Rewards (Bonus)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: themeController.textColor,
                              ),
                            ),
                            SizedBox(height: 15),
                            GuideText(
                              title: "After GET ZEROKOIN, tap \"More Rewards\"",
                            ),
                            GuideText(
                              title:
                                  "Follow our social media pages to receive \n extra ZeroKoins as a bonus",
                            ),
                            SizedBox(height: 20),
                            Image.asset("assets/ff2.png"),
                            SizedBox(height: 20),
                            Text(
                              "Learn And Earn Daily Rewards:",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 25,
                                color: themeController.textColor,
                              ),
                            ),
                            SizedBox(height: 30),
                            GuideText(
                              title: "Learn & Earn - Daily Learning Rewards",
                            ),
                            GuideText(title: "Go to the learning sections."),
                            GuideText(
                              title: "Every day, you'll get 5 pages to read.",
                            ),
                            GuideText(
                              title:
                                  "Each page requires you to read and \n understand for 2 minutes.",
                            ),
                            GuideText(
                              title: "After 2 minutes, the \"Next\" button will appear to go to next page.",
                            ),
                            GuideText(
                              title:
                                  "When you complete all 5 pages in a day, \n you'll earn 10 ZeroKoins as a reward",
                            ),
                            SizedBox(height: 20),
                            Image.asset("assets/ff3.png"),
                            SizedBox(height: 20),
                            Text(
                              "How to Add ZeroKoin to MetaMask & Get Your Address:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: themeController.textColor,
                              ),
                            ),
                            SizedBox(height: 30),
                            GuideText(
                              title:
                                  "Go to the Play Store and search for \n MetaMask.",
                            ),
                            GuideText(
                              title: "Download and install the MetaMask app.",
                            ),
                            GuideText(
                              title: "Open the app and tap \"Add\"",
                            ),
                            GuideText(
                              title: "Select \"Custom Token\"",
                            ),
                            GuideText(
                              title:
                                  "Paste the following ZeroKoin contract \n address:",
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 38.0),
                              child: GestureDetector(
                                onTap: () {
                                  Clipboard.setData(const ClipboardData(text: "0x99349F73449b2BDFa63deFB05770df04fD70E97"));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Address copied to clipboard!')),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "0x99349F73449b2BDFa63deFB05770df04fD70E97",
                                        style: TextStyle(color: Colors.blue),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Image.asset("assets/copy.png"),
                                  ],
                                ),
                              ),
                            ),
                            GuideText(
                              title: "Tap the \"Next\" button.",
                            ),
                            GuideText(
                              title: "Confirm that the token shows 0 KOIN.",
                            ),
                            GuideText(
                              title: "Tap \"Next\" again.",
                            ),
                            GuideText(
                              title: "You will see a message: \"Import Successful\"",
                            ),
                            GuideText(
                              title: "Tap the \"Import\" button to finish.",
                            ),
                            GuideText(
                              title: "Tap ZeroKoin, then tap \"Receive\" to view your ZeroKoin wallet address.",
                            ),
                            SizedBox(height: 20),
                            Image.asset("assets/gg4.png"),
                            SizedBox(height: 20),
                            Text(
                              "Invite & Earn:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: themeController.textColor,
                              ),
                            ),
                            GuideText(
                              title: 'Step 1: "Invite & Earn" Enter this section.',
                            ),
                            GuideText(
                              title:
                                  "Step 2: Here you can copy or share your\n reference number",
                            ),
                            GuideText(
                              title:
                                  "After your friend clicks on the link and\n installs the application and registers, you\n will be rewarded.",
                            ),
                            SizedBox(height: 20),
                            Image.asset(
                              "assets/gg5.png",
                              width: double.infinity,
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
