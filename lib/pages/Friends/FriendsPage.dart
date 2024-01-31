// ignore_for_file: unnecessary_string_escapes

import 'dart:typed_data';

import 'package:bruh/firebaseController/chatroomDbController.dart';
import 'package:bruh/firebaseController/userDbController.dart';
import 'package:bruh/helper/SharedPreference.dart';
import 'package:bruh/model/user.dart';
import 'package:bruh/pages/Friends/ChatPage.dart';
import 'package:bruh/pages/Friends/FriendRequests.dart';
import 'package:bruh/pages/General/SearchPeople.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendsChat extends StatefulWidget {
  const FriendsChat({super.key});

  @override
  State<FriendsChat> createState() => _FriendsChatState();
}

class _FriendsChatState extends State<FriendsChat> {
  Stream? chatRoomsStream;
  String myuid = SharedPrefs().uid;

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  ontheload() async {
    final chatroomController = Get.put(ChatRoomRepository());
    chatRoomsStream = await chatroomController.getChatRooms();
    setState(() {});
  }

  Widget chatRoomList() {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var ds = snapshot.data.docs[index];
                    String uid =
                        (ds.id).replaceAll("_", "").replaceAll(myuid, "");
                    return ChatTile(
                        uid: uid,
                        chatroomid: ds.id,
                        lastmessage: ds["lastMessage"],
                        time: ds["lastMessageSendTs"]);
                  })
              : const Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10.0,
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const searchPeople()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(width: 1.0, color: Colors.grey),
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                foregroundColor: Colors.black,
              ),
              child: const Row(
                children: [
                  Icon(Icons.search),
                  Text('Search'),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FriendRequests()));
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
                child: Row(
                  children: [
                    Icon(Icons.person_add),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      'Friend requests',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_right)
                  ],
                ),
              ),
            ),
            chatRoomList(),
          ],
        ),
      ),
    ));
  }
}

class ChatTile extends StatefulWidget {
  const ChatTile(
      {super.key,
      required this.uid,
      required this.chatroomid,
      required this.lastmessage,
      required this.time});
  final String uid;
  final String chatroomid;
  final String lastmessage;
  final String time;

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  late UserRepo user;

  getUserDetail(String uid) async {
    final userController = Get.put(UserRepository());
    user = await userController.getUserDetails(uid);
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserDetail(widget.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatPage(
                          uid: user.uid,
                          name: user.name,
                          profile: user.profile)));
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.memory(
                        Uint8List.fromList(user.profile.codeUnits),
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
                        user.name,
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
                          widget.lastmessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    widget.time,
                    style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(
            child: Text('No Friends'),
          );
        }
      },
    );
  }
}
