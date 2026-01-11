import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart' show GetNavigation;
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zero_koin/controllers/theme_controller.dart';
import 'package:zero_koin/controllers/user_controller.dart';
import 'package:zero_koin/view/FAQs_screen.dart';
import 'package:zero_koin/view/home_screen.dart';
import 'package:zero_koin/view/notification_page.dart';
import 'package:zero_koin/widgets/my_drawer.dart';
import 'package:zero_koin/widgets/notification_badge.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final String inviteLink = "https://zerokoin.com/inviteABD123";
  bool _isCopied = false;

  // Function to copy to clipboard
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: inviteLink,)).then((_) {
      setState(() {
        _isCopied = true;
      });

      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Link copied to clipboard!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0XFF00B772),
        ),
      );

      // Reset copied state after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isCopied = false;
          });
        }
      });
    });
  }

  // Function to share invite link
  void _shareInviteLink() {
    Share.share(
      'Join me on Zero Koins! Use my invite link: $inviteLink\n\nEarn 50 ZRK for each new user!',
      subject: 'Join Zero Koins with my referral',
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
      final ThemeController themeController = Get.find<ThemeController>();
    final UserController userController = Get.find<UserController>();

    return Scaffold(
      backgroundColor: themeController.isDarkMode?Colors.black:Colors.white,
        drawer: MyDrawer(),
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                // Gradient background container (WITHOUT the black header)
                Container(
                  height: 440,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(17.5),
                      bottomRight: Radius.circular(17.5),
                    ),
                    gradient: LinearGradient(
                      colors: [Color(0xFF0683A3), Color(0xFFA09E17)],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Add empty space for the fixed header
                      
Padding(
  padding: const EdgeInsets.only(top: 127),
  child: Row(
    children: [SizedBox(width: 8,),
      IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));}, icon: Icon(Icons.arrow_back,color: Colors.white,size: 28,)),SizedBox(width: 8,),Text("Invite Friends",style: TextStyle(fontSize: 18,color: Colors.white,fontFamily: "Coolvetica",fontWeight: FontWeight.w500),)
    ],
  ),
),
                      Padding(
                        padding: const EdgeInsets.only(right: 145,),
                        child: Text(
                          "What you Earn for\neach new user:\n50 ZRK",
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: "Coolvetica",
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 60, left: 35),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 75,
                              width: 75,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    left: -72,
                                    bottom: 10,
                                    child: Image.asset(
                                      "assets/leaf.png",
                                      height: 150,
                                      width: 150,
                                    ),
                                  ),
                                  Container(
                                    height: 75,
                                    width: 75,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 18,
                                          ),
                                          child: Image.asset(
                                            "assets/Mask group.png",
                                            height: 22,
                                            width: 22,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: Container(
                                            height: 20,
                                            width: 75,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                topRight: Radius.circular(16),
                                              ),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFFA09E17),
                                                  Color(0xFF0683A3),
                                                ],
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Mining",
                                                style: TextStyle(
                                                  fontFamily: "Poppins",
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 1),
                                        Text(
                                          userController.balance.value.toString(),
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontFamily: "Poppins",
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Positioned(
                                    left: 130,
                                    top: -220,
                                    child: Image.asset(
                                      "assets/Asset 1@3x 1.png",
                                      width: 240,
                                      height: 240,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 10),
                            Container(
                              height: 75,
                              width: 75,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 18),
                                    child: Image.asset(
                                      "assets/Mans.png",
                                      height: 22,
                                      width: 22,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Container(
                                      height: 20,
                                      width: 75,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFA09E17),
                                            Color(0xFF0683A3),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Refferences",
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 1),
                                  Text(
                                    "0",
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontFamily: "Poppins",
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),

                            Container(
                              height: 75,
                              width: 75,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 18),
                                    child: Image.asset(
                                      "assets/Refferals3.png",
                                      height: 22,
                                      width: 22,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Container(
                                      height: 20,
                                      width: 75,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFA09E17),
                                            Color(0xFF0683A3),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Refferrals",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: "Poppins",
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 1),
                                  Text(
                                    "0",
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontFamily: "Poppins",
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),

                            Container(
                              height: 75,
                              width: 75,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 18),
                                    child: Image.asset(
                                      "assets/power4.png",
                                      height: 22,
                                      width: 22,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Container(
                                      height: 20,
                                      width: 75,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFA09E17),
                                            Color(0xFF0683A3),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Power",
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 1),
                                  Text(
                                    "1/4",
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontFamily: "Poppins",
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // Invite Friend Section
                Column(
                  children: [
                    // Invite Header with Share Button
                    Container(
                      height: 45,
                      width: 330,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0683A3), Color(0xFFA09E17)],
                        ),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(25),
                          topLeft: Radius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Invite Friend ",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 50),
                          GestureDetector(
                            onTap: _shareInviteLink,
                            child: Image.asset(
                              "assets/share-1_2.png",
                              width: 18.36,
                              height: 18.36,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Link with Copy Button
                    Container(
                      height: 45,
                      width: 330,
                      decoration: BoxDecoration(
                        color: themeController.cardColor,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              inviteLink,
                              style: TextStyle(
                                fontFamily: "Poppins-regular",
                                fontSize: 13, color: themeController.isDarkMode?Colors.white:Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: _copyToClipboard,
                            child: Container(
                              height: 28,
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color:
                                    _isCopied ? Colors.grey : Color(0XFF00B772),
                              ),
                              child: Center(
                                child: Text(
                                  _isCopied ? "Copied!" : "Copy",
                                  style: TextStyle(
                                    fontFamily: "Poppins-regular",
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                        ],
                      ),
                    ),

                    SizedBox(height: 25),

                    // How It Works Section
                    Container(
                      height: 180,
                      width: 330,
                      decoration: BoxDecoration(
                        
                        borderRadius: BorderRadius.circular(25),
                        color: themeController.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, left: 25),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 155),
                              child: Text(
                                "How It works?",
                                style: TextStyle(
                                  fontFamily: "Coolvetica",
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: themeController.textColor,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Image.asset("assets/Group 8.png",color: themeController.isDarkMode?Colors.white:Colors.black,),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Share your invite link",
                                    style: TextStyle(
                                      fontFamily: "Poppins-regular",
                                      fontSize: 16,
                                      color: themeController.textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Image.asset("assets/Group 7.png",color: themeController.isDarkMode?Colors.white:Colors.black,),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Your friend joins Zero Koins",
                                    style: TextStyle(
                                      fontFamily: "Poppins-regular",
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: themeController.textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Image.asset("assets/Group 9.png",color: themeController.isDarkMode?Colors.white:Colors.black,),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "You earn rewards automatically",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: themeController.textColor,
                                      fontFamily: "Poppins-regular",
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 25),

                    // FAQ Section
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Stack(
                            children: [
                              Image.asset("assets/Group 16.png"),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 305,
                                  top: 120,
                                ),
                                child: Image.asset("assets/Isolation_Mode.png"),
                              ),
                            ],
                          ),
                        ),
  
  FAQScreen(),
                      ],
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ],
            ),
          ),

          // Fixed header on top of everything
          SafeArea(
      top: false,
      child: Container(
        height: screenHeight * 0.15,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
                   
                 
          border: Border(
            bottom: BorderSide(color: Color(0xFF505050), width: 2),
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder:
                          (context) => GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF0682A2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(8),
                              width: 50,
                              height: 40,
                              child: SvgPicture.asset(
                                "assets/menu.svg",
                                width: 29,
                                height: 28,
                              ),
                            ),
                          ),
                    ),
                    Image.asset(
                      "assets/zero_koin_logo.png",
                      height: screenHeight * 0.05,
                      width: screenWidth * 0.16,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => NotificationPage());
                      },
                      child:Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0682A2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(8),
                            width: 50,
                            height: 40,
                            child: SvgPicture.asset(
                              "assets/not.svg",
                              width: 29,
                              height: 28,
                            ),
                          ),
                        
                      
                    ),
                  ],
                ),
                
              ],
            ),
          ),
        ),
      ),
    )

          ],
      ),
    );
  }
}

