import 'dart:typed_data';

import 'package:bruh/firebaseController/chatroomDbController.dart';
import 'package:bruh/firebaseController/friendrequestDbController.dart';
import 'package:bruh/firebaseController/userDbController.dart';
import 'package:bruh/model/friendrequest.dart';
import 'package:bruh/model/user.dart';
import 'package:bruh/pages/Friends/ChatPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PersonClass {
  final String uid;
  final String registernumber;
  final String name;
  final String gender;
  final String nativestate;
  final String hosteller;
  final String profile;
  final int friend;

  const PersonClass({
    required this.uid,
    required this.registernumber,
    required this.name,
    required this.gender,
    required this.nativestate,
    required this.hosteller,
    required this.profile,
    required this.friend,
  });
}

class Controllers {
  late String currentuid;
  late String useruid;
  late DocumentReference _documentReference;
  final friendrequestController = Get.put(FriendRequestRepository());
  final userController = Get.put(UserRepository());
  final chatroomController = Get.put(ChatRoomRepository());

  void sendFriendRequest(String uid) async {
    var timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    FriendRequestRepo request = FriendRequestRepo(
        senderuid: currentuid,
        receiveruid: uid,
        time: timestamp,
        participants: [currentuid, uid]);
    friendrequestController.createfriendrequest(request);
  }

  void deleteRequest() async {
    await _documentReference.delete();
  }

  Future<void> updateFriendList(String uid, String adduid) async {
    //First Reference
    var reference1 = await userController.getUserDetailsReference(uid);
    QuerySnapshot<Map<String, dynamic>> documentSnapshot1 =
        await reference1.get();
    final document1 = documentSnapshot1.docs.first;
    List<String> existingFriends1 =
        List<String>.from(document1['friends'] ?? []);
    existingFriends1.add(adduid);
    await documentSnapshot1.docs.first.reference.set({
      'friends': existingFriends1,
    }, SetOptions(merge: true));

    //Second reference
    var reference2 = await userController.getUserDetailsReference(adduid);
    QuerySnapshot<Map<String, dynamic>> documentSnapshot2 =
        await reference2.get();
    final document2 = documentSnapshot2.docs.first;
    List<String> existingFriends2 =
        List<String>.from(document2['friends'] ?? []);
    existingFriends2.add(uid);
    await documentSnapshot2.docs.first.reference.set({
      'friends': existingFriends2,
    }, SetOptions(merge: true));
  }

  String getChatRoomID(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }
}

class Person extends StatefulWidget {
  const Person({super.key, required this.uid});
  final String uid;

  @override
  State<Person> createState() => _PersonState();
}

class _PersonState extends State<Person> {
  late Controllers _controller;

  @override
  void initState() {
    super.initState();
    _controller = Controllers();
    _controller.currentuid = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<PersonClass> getPerson() async {
    int friendType;

    UserRepo user = await _controller.userController.getUserDetails(widget.uid);
    QuerySnapshot<Map<String, dynamic>> document = await _controller
        .friendrequestController
        .friendrequestexists(_controller.currentuid, widget.uid);
    List friends = user.friends;
    if (document.size == 0) {
      if (friends.contains(_controller.currentuid)) {
        friendType = 4;
      } else {
        friendType = 1;
      }
    } else {
      final data = document.docs[0];
      _controller._documentReference = document.docs[0].reference;
      if (data['senderuid'] == _controller.currentuid) {
        friendType = 2;
      } else if ((data['senderuid'] != _controller.currentuid)) {
        friendType = 3;
      } else {
        friendType = 0;
      }
    }

    PersonClass person = PersonClass(
        uid: widget.uid,
        registernumber: user.registernumber,
        name: user.name,
        gender: user.gender,
        nativestate: user.nativestate,
        hosteller: user.hosteller,
        profile: user.profile,
        friend: friendType);
    return person;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Mulish',
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.black,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder(
          future: getPerson(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                final data = snapshot.data;
                return SingleChildScrollView(
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 30.0,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(120),
                            child: Image.memory(
                              Uint8List.fromList(data!.profile.codeUnits),
                              height: 150.0,
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            data.name,
                            style: const TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 30.0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(data.registernumber),
                          const SizedBox(
                            height: 40.0,
                          ),
                          Row(
                            children: [
                              const Text(
                                "Gender",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Mulish'),
                              ),
                              const Spacer(),
                              Text(data.gender),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                "Native State",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Mulish'),
                              ),
                              const Spacer(),
                              Text(data.nativestate),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                "Hosteller",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Mulish'),
                              ),
                              const Spacer(),
                              Text(data.hosteller),
                            ],
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          if (_controller.currentuid != data.uid)
                            ButtonWidget(
                              uid: data.uid,
                              data: data,
                              controller: _controller,
                            )
                        ],
                      ),
                    ),
                  ),
                );
              }
            }
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            );
          }),
    );
  }
}

class ButtonWidget extends StatefulWidget {
  const ButtonWidget(
      {super.key,
      required this.uid,
      required this.controller,
      required this.data});
  final String uid;
  final PersonClass data;
  final Controllers controller;

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  late int friendtype;
  late PersonClass data;
  late Controllers controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    data = widget.data;
    friendtype = widget.data.friend;
  }

  @override
  Widget build(BuildContext context) {
    if (friendtype == 1) {
      return ElevatedButton(
          style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: const StadiumBorder(),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white),
          onPressed: () {
            controller.sendFriendRequest(widget.uid);
            setState(() {
              friendtype = 2;
            });
          },
          child: const Text('Send request'));
    } else if (friendtype == 2) {
      return ElevatedButton(
          style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: const StadiumBorder(),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white),
          onPressed: null,
          child: const Text('Request sent'));
    } else if (friendtype == 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white),
                onPressed: () async {
                  await controller.updateFriendList(
                      controller.currentuid, widget.uid);
                  controller.deleteRequest();
                  setState(() {
                    friendtype = 4;
                  });
                },
                child: const Text('Accept')),
          ),
          const SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white),
                onPressed: () async {
                  controller.deleteRequest();
                  setState(() {
                    friendtype = 1;
                  });
                },
                child: const Text('Reject')),
          )
        ],
      );
    } else if (friendtype == 4) {
      return ElevatedButton(
          style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: const StadiumBorder(),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white),
          onPressed: () async {
            var roomID =
                controller.getChatRoomID(controller.currentuid, widget.uid);
            Map<String, dynamic> users = {
              "users": [controller.currentuid, widget.uid]
            };
            await controller.chatroomController.createChatRoom(roomID, users);
            // ignore: use_build_context_synchronously
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatPage(
                          uid: widget.uid,
                          name: data.name,
                          profile: data.profile,
                        )));
          },
          child: const Text('Chat'));
    }
    return Container();
  }
}
