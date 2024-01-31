// ignore_for_file: use_key_in_widget_constructors

import 'package:bruh/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'login_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({Key? key});
  static const String id = 'onboarding';
  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Image.asset(
            "assets/images/logo.png",
            height: (MediaQuery.of(context).size.height / 100) * 5,
          ),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle:
            const SystemUiOverlayStyle(systemNavigationBarColor: Colors.black),
      ),
      body: const OnboardingWidget(), // Use OnboardingWidget here
    );
  }
}

class OnboardingWidget extends StatelessWidget {
  const OnboardingWidget({Key? key});

  @override
  Widget build(BuildContext context) {
    // Height and Width of Screen
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: screenHeight,
      width: screenWidth,
      child: Column(
        children: [
          const Spacer(),
          Image.asset(
            "assets/images/onboarding.png",
            height: (screenHeight / 100) * 35,
          ),
          SizedBox(
            height: (screenHeight >= 840) ? 60 : 30,
          ),
          Text(
            "Welcome to Bruh!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "Ahsing",
              fontWeight: FontWeight.w200,
              fontSize: (screenWidth <= 550) ? 30 : 35,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Time to be Social!",
            style: TextStyle(
                fontFamily: "Mulish",
                fontWeight: FontWeight.w400,
                fontSize: (screenWidth <= 550) ? 17 : 25,
                color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Container(
            width: screenWidth,
            color: Colors.black,
            child: Column(
              children: [
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 3.0, color: Colors.white),
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(60),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0))),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      'Get Started!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: "Mulish",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
