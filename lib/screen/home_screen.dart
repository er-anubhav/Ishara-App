import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:docuhealth/contstants/app_colors.dart';
import 'package:docuhealth/screen/scanner/camera_screen.dart';
import 'package:docuhealth/screen/dashboard/dashboard.dart';
import 'package:docuhealth/screen/dashboard/knowledge.dart';
import 'package:docuhealth/screen/dashboard/nearby.dart';
import 'package:docuhealth/screen/dashboard/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  final int currentIndex;
  const HomePage({Key? key, required this.currentIndex}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> animation;
  late CurvedAnimation curve;

  List iconList = [
    {'icon': Icons.home_filled, 'title': 'Home'},
    {'icon': Icons.map_outlined, 'title': 'Nearby'},
    {'icon': Icons.file_copy, 'title': 'Knowledge'},
    {'icon': Icons.view_compact_alt_sharp, 'title': 'More'}
  ];

  void onTabTapped(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
    _pageController.animateToPage(index,
        curve: Curves.easeIn, duration: const Duration(milliseconds: 250));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future _onWillPop() async {}

  @override
  void initState() {
    _currentIndex = widget.currentIndex;
    final systemTheme = SystemUiOverlayStyle(
        statusBarColor: AppColors.whitebgColor,
        systemNavigationBarColor: Colors.black,
        statusBarIconBrightness: Brightness.dark);
    SystemChrome.setSystemUIOverlayStyle(systemTheme);

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    curve = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.5,
        1.0,
        curve: Curves.fastOutSlowIn,
      ),
    );
    animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(curve);

    Future.delayed(
      const Duration(seconds: 1),
      () => _animationController.forward(),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await _onWillPop(),
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          allowImplicitScrolling: false,
          physics: const NeverScrollableScrollPhysics(),
          children: const <Widget>[
            Dashboard(),
            NearByScreen(),
            KnowledgeScreen(),
            ProfileScreen(),
          ],
        ),
        floatingActionButton: ScaleTransition(
          scale: animation,
          child: FloatingActionButton(
            elevation: 8,
            backgroundColor: AppColors.primaryColor,
            child: Icon(
              Icons.document_scanner,
              size: 40.r,
              color: AppColors.whitebgColor,
            ),
            onPressed: () {
              Get.to(const CameraScreen(
                appBarTitle: '',
              ));
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedBottomNavigationBar.builder(
            itemCount: iconList.length,
            tabBuilder: (int index, bool isActive) {
              final color = isActive
                  ? AppColors.primaryColor
                  : AppColors.lightGreyTextColor;
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconList[index]['icon'],
                    size: 24.r,
                    color: color,
                  ),
                  SizedBox(height: 4.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Text(
                      iconList[index]['title'],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(
                        color: color,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              );
            },
            backgroundColor: AppColors.whitebgColor,
            activeIndex: _currentIndex,
            splashColor: Colors.yellow,
            notchAndCornersAnimation: animation,
            splashSpeedInMilliseconds: 300,
            notchSmoothness: NotchSmoothness.defaultEdge,
            gapLocation: GapLocation.center,
            onTap: (index) {
              if (mounted) {
                setState(() {
                  _currentIndex = index;
                  onTabTapped(index);
                });
              }
            }),
      ),
    );
  }
}
