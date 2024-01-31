import 'package:bruh/helper/SharedPreference.dart';
import 'package:bruh/onboarding_page.dart';
import 'package:bruh/pages/Group/GroupPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'pages/Community/CommunityPage.dart';
import 'pages/Friends/FriendsPage.dart';
import 'pages/Random/RandomPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String id = 'homepage';
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  final _pageController = PageController();

  int _selectedIndex = 0;
  final List<Widget> _screen = [
    const RandomPage(),
    const FriendsChat(),
    const GroupPage(),
    const Community(),
  ];

  popup(BuildContext context, item) {
    switch (item) {
      case 0:
        SharedPrefs().clear();
        _auth.signOut();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => const OnboardingPage(),
          ),
          (Route route) => false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle:
            const SystemUiOverlayStyle(systemNavigationBarColor: Colors.black),
        title: const Text(
          'Bruh!',
          style: TextStyle(
              color: Colors.white,
              fontSize: 30.0,
              fontFamily: 'Mulish',
              fontWeight: FontWeight.w800),
        ),
        actions: [
          PopupMenuButton(
            elevation: 1,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            offset: const Offset(0, 60),
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 0,
                child: Text('Logout'),
              )
            ],
            onSelected: (item) => popup(context, item),
          )
        ],
        backgroundColor: Colors.black,
        elevation: 0.0,
      ),
      body: PageView(
        onPageChanged: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        controller: _pageController,
        children: _screen,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: const NavigationBarThemeData(
            backgroundColor: Colors.black,
            indicatorColor: Colors.white,
            labelTextStyle: MaterialStatePropertyAll(
                TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        child: NavigationBar(
          animationDuration: const Duration(seconds: 0),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          height: 50.0,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (value) {
            setState(() {
              _selectedIndex = value;
              _pageController.animateToPage(_selectedIndex,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.linear);
            });
          },
          destinations: const [
            NavigationDestination(
                selectedIcon: Icon(
                  Icons.chat_bubble,
                  color: Colors.black,
                ),
                icon: Icon(
                  Icons.chat_bubble,
                  color: Colors.white,
                ),
                label: "Chat"),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.person,
                color: Colors.black,
              ),
              icon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              label: 'Friends',
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.class_,
                color: Colors.black,
              ),
              icon: Icon(
                Icons.class_,
                color: Colors.white,
              ),
              label: 'Groups',
            ),
            NavigationDestination(
                selectedIcon: Icon(
                  Icons.people,
                  color: Colors.black,
                ),
                icon: Icon(
                  Icons.people,
                  color: Colors.white,
                ),
                label: "Community"),
          ],
        ),
      ),
    );
  }
}
