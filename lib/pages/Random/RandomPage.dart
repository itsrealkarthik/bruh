import 'package:bruh/helper/SharedPreference.dart';
import 'package:bruh/pages/Random/RandomChatPage.dart';
import 'package:flutter/material.dart';

class RandomPage extends StatefulWidget {
  const RandomPage({super.key});

  @override
  State<RandomPage> createState() => _RandomPageState();
}

class _RandomPageState extends State<RandomPage> {
  final myuid = SharedPrefs().uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SafeArea(
          child: Center(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.black,
                    shape: const StadiumBorder()),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RandomChatPage(),
                      ));
                },
                child: const Text("Connect with new people")),
          ),
        ),
      ),
    );
  }
}
