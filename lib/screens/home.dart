import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/constants/firebase_consts.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/screens/reel_screen.dart';

import '../constants/colors.dart';
import 'add_post_screen.dart';
import 'feed_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<Home> {
  UserModel? user;
  int _page = 0;
  late PageController pageController; // for tabs animation
  final authController = Get.put(AuthController());
  @override
  void initState() {
    getData();
    super.initState();

    pageController = PageController();
  }

  getData() async {
    user = await authController.getUserData();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        
        controller: pageController,
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: mobileBackgroundColor,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: (_page == 0) ? primaryColor : secondaryColor,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                color: (_page == 1) ? primaryColor : secondaryColor,
              ),
              label: '',
              backgroundColor: primaryColor),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.add_circle,
                color: (_page == 2) ? primaryColor : secondaryColor,
              ),
              label: '',
              backgroundColor: primaryColor),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/reel.svg',
              color: (_page == 3) ? primaryColor : secondaryColor,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _page == 4 ? Colors.white : Colors.transparent,
                      width: 2)),
              child: CircleAvatar(
                backgroundImage: user != null
                    ? NetworkImage(user!.photoUrl.toString())
                    : const NetworkImage('https://i.stack.imgur.com/l60Hf.png'),
              ),
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
        ],
        onTap: navigationTapped,
        currentIndex: _page,
      ),
    );
  }
}

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const ReelScreen(),
  ProfileScreen(uid: auth.currentUser!.uid),
];
