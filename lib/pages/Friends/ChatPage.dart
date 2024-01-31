// ignore_for_file: unnecessary_string_escapes

import 'package:bruh/firebaseController/chatroomDbController.dart';
import 'package:bruh/firebaseController/userDbController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:readmore/readmore.dart';

class Controllers extends GetxController {
  late String currentuid, chatRoomId, profile;
  String? messageId;
  TextEditingController messagecontroller = TextEditingController();
  final userController = Get.put(UserRepository());
  final chatroomController = Get.put(ChatRoomRepository());

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
        'profile': profile,
      };
      messageId ??= randomAlphaNumeric(20);
      chatroomController
          .addMessage(chatRoomId, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "lastMessageSendBy": currentuid,
          'profile': profile,
        };

        chatroomController.updateLastMessageSend(
            chatRoomId, lastMessageInfoMap);
        if (sendClicked) {
          messageId = null;
        }
      });
    }
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key,
      required this.uid,
      required this.name,
      required this.profile});
  final String uid;
  final String name;
  final String profile;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Controllers _controller;
  Stream? messagestream;

  Query<Map<String, dynamic>> getQuery() {
    final FirebaseFirestore _db = FirebaseFirestore.instance;
    Query<Map<String, dynamic>> query = _db
        .collection('chatrooms')
        .doc(_controller.chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true);
    return query;
  }

  onload() async {
    _controller = Controllers();
    _controller.profile = widget.profile;
    _controller.currentuid = FirebaseAuth.instance.currentUser!.uid;
    _controller.chatRoomId = getChatRoomId(_controller.currentuid, widget.uid);
    await getAndSetMessages(_controller.chatRoomId);
    setState(() {});
  }

  getAndSetMessages(String chatRoomId) async {
    messagestream =
        await _controller.chatroomController.getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
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
          widget.name,
          style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Mulish',
              fontWeight: FontWeight.w800),
        ),
        toolbarHeight: 80.0,
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
            margin:
                const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
            alignment: Alignment.bottomCenter,
            child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
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
