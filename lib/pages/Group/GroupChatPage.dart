// ignore_for_file: unnecessary_string_escapes

import 'package:bruh/firebaseController/groupDbController.dart';
import 'package:bruh/firebaseController/userDbController.dart';
import 'package:bruh/pages/Group/AlertHub.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:readmore/readmore.dart';

class Controllers extends GetxController {
  late String currentuid, name, chatRoomId;
  String? messageId;
  TextEditingController messagecontroller = TextEditingController();
  final userController = Get.put(UserRepository());
  final groupController = Get.put(GroupRepository());

  addMessage(bool sendClicked) {
    if (messagecontroller.text != "") {
      String message = messagecontroller.text;
      messagecontroller.text = "";
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(now);
      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": currentuid,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
      };
      messageId ??= randomAlphaNumeric(20);
      groupController.addMessage(chatRoomId, messageId!, messageInfoMap);
    }
  }
}

class GroupChatPage extends StatefulWidget {
  const GroupChatPage({super.key, required this.number, required this.code});
  final String number;
  final String code;

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  late Controllers _controller;

  Query<Map<String, dynamic>> getQuery() {
    final FirebaseFirestore _db = FirebaseFirestore.instance;
    Query<Map<String, dynamic>> query = _db
        .collection('groups')
        .doc(_controller.chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true);
    return query;
  }

  onload() async {
    _controller = Controllers();
    _controller.chatRoomId = widget.number;
    _controller.currentuid = FirebaseAuth.instance.currentUser!.uid;
    setState(() {});
  }

  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
            child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(8),
                  bottomRight: sendByMe
                      ? const Radius.circular(0)
                      : const Radius.circular(8),
                  topRight: const Radius.circular(8),
                  bottomLeft: sendByMe
                      ? const Radius.circular(8)
                      : const Radius.circular(0)),
              color: sendByMe
                  ? const Color.fromARGB(255, 234, 236, 240)
                  : const Color.fromARGB(255, 211, 228, 243)),
          child: Column(
            crossAxisAlignment:
                sendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ReadMoreText(
                message,
                trimLines: 5,
                trimMode: TrimMode.Line,
                trimCollapsedText: 'Show more',
                trimExpandedText: 'Show less',
                style: const TextStyle(
                    fontFamily: 'Mulish',
                    color: Colors.black,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget chatMessage() {
    return FirestoreListView<Map<String, dynamic>>(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100.0, top: 10),
      reverse: true,
      query: getQuery(),
      itemBuilder: (context, doc) {
        final ds = doc.data();
        return chatMessageTile(
            ds["message"], _controller.currentuid == ds["sendBy"]);
      },
      loadingBuilder: (context) {
        return const LinearProgressIndicator(
          backgroundColor: Colors.white,
          color: Colors.black,
        );
      },
    );
  }

  popup(BuildContext context, item) {
    switch (item) {}
  }

  @override
  void initState() {
    super.initState();
    onload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.code,
          style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Mulish',
              fontWeight: FontWeight.w800),
        ),
        actions: [
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlertHub(
                        chatroomid: widget.number,
                      ),
                    ));
              },
              child: const Icon(Icons.all_inbox)),
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
                child: Text('Group info'),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Text('Alert hub'),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Text('Search'),
              ),
            ],
            onSelected: (item) => popup(context, item),
          )
        ],
        backgroundColor: Colors.black,
        elevation: 0.0,
        centerTitle: true,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Container(child: chatMessage()),
          Container(
            margin: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
            alignment: Alignment.bottomCenter,
            child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)),
                child: TextField(
                  minLines: 1,
                  maxLines: 4,
                  controller: _controller.messagecontroller,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Type a message",
                      hintStyle: const TextStyle(color: Colors.black45),
                      suffixIcon: GestureDetector(
                          onTap: () {
                            _controller.addMessage(true);
                          },
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.black,
                            size: 30.0,
                          ))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
