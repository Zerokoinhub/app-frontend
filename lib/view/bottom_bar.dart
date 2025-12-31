import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zero_koin/controllers/admob_controller.dart';
import 'package:zero_koin/view/calculator_screen.dart';
import 'package:zero_koin/view/home_screen.dart';
import 'package:zero_koin/view/learn_and_earn.dart';
import 'package:zero_koin/view/user_profile_screen.dart';
import 'package:zero_koin/view/wallet_screen.dart';
import 'package:zero_koin/controllers/home_controller.dart';
import 'package:get/get.dart';

class BottomBar extends StatefulWidget {
  final int initialIndex;
  const BottomBar({super.key, this.initialIndex = 0});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  late int _currentIndex;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure the current index is valid
    if (_currentIndex >= _pages.length) {
      _currentIndex = 0;
    }
  }

  final List<Widget> _pages = [
    HomeScreen(),
    WalletScreen(),
    LearnAndEarn(),
    CalculatorScreen(),
    UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return CurvedNavigationBar(
      key: _bottomNavigationKey,
      index: _currentIndex,
      backgroundColor: Color.fromARGB(255, 29, 28, 28),
      buttonBackgroundColor: Color(0xFF0682A2),
      color: Colors.black,
      height: 60,
      animationDuration: Duration(milliseconds: 300),
      animationCurve: Curves.easeInOut,
      items: <Widget>[
        SvgPicture.asset(
          'assets/Home Button Icon.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        Image(
          image: AssetImage('assets/wallet.png'),
          color: Colors.white,
          width: 24,
          height: 24,
          colorBlendMode: BlendMode.srcIn,
        ),
        Image(
          image: AssetImage('assets/education.png'),
          color: Colors.white,
          width: 24,
          height: 24,
          colorBlendMode: BlendMode.srcIn,
        ),
        Image(
          image: AssetImage('assets/calculator.png'),
          color: Colors.white,
          width: 24,
          height: 24,
          colorBlendMode: BlendMode.srcIn,
        ),
        Image(
          image: AssetImage('assets/user_profile.png'),
          color: Colors.white,
          width: 24,
          height: 24,
          colorBlendMode: BlendMode.srcIn,
        ),
      ],
      onTap: (index) {
        // Prevent duplicate taps
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
          
          // Trigger refresh data on HomeController when home is tapped
          if (index == 0) {
            try {
              final HomeController homeController = Get.find<HomeController>();
              homeController.refreshData();
            } catch (e) {
              print("HomeController not found: $e");
            }
          }
        }
      },
    );
  }
}