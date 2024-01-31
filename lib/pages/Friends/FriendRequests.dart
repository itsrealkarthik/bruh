import 'dart:typed_data';

import 'package:bruh/firebaseController/friendrequestDbController.dart';
import 'package:bruh/firebaseController/userDbController.dart';
import 'package:bruh/helper/SharedPreference.dart';
import 'package:bruh/model/user.dart';
import 'package:bruh/pages/General/Person.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Requests {
  final String uid;
  final String name;
  final String profile;
  final String registernumber;

  Requests({
    required this.uid,
    required this.profile,
    required this.registernumber,
    required this.name,
  });
}

class FriendRequests extends StatefulWidget {
  const FriendRequests({super.key});

  @override
  State<FriendRequests> createState() => _FriendRequestsState();
}

class _FriendRequestsState extends State<FriendRequests> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Friend requests',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Mulish',
              fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.black,
        elevation: 0.0,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 50.0,
                ),
                Request(),
              ],
            ),
          )),
    );
  }
}

class Request extends StatefulWidget {
  const Request({super.key});

  @override
  State<Request> createState() => _RequestState();
}

class _RequestState extends State<Request> {
  String myuid = SharedPrefs().uid;
  List<Requests> list = [];

  getAllRequests() async {
    list = [];
    final requestController = Get.put(FriendRequestRepository());
    final userController = Get.put(UserRepository());
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await requestController.getallfriendrequests(myuid);

    for (var post in querySnapshot.docs) {
      UserRepo user = await userController.getUserDetails(post['senderuid']);
      Requests req = Requests(
          uid: user.uid,
          profile: user.profile,
          registernumber: user.registernumber,
          name: user.name);
      list.add(req);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAllRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            if (list.isEmpty) {
              return const Center(child: Text('No Requests'));
            } else {
              return ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Person(uid: list[index].uid),
                            ));
                      },
                      child: Row(children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.memory(
                              Uint8List.fromList(list[index].profile.codeUnits),
                              height: 50.0,
                              fit: BoxFit.cover,
                            )),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 6.0,
                            ),
                            Text(
                              list[index].name,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 4.0,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Text(
                                list[index].registernumber,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.black45,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ]),
                    );
                  });
            }
          } else {
            return const Center(child: Text('No Requests'));
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
