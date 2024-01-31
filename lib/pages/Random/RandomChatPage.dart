// ignore_for_file: unnecessary_string_escapes, use_build_context_synchronously

import 'package:bruh/firebaseController/randomchatDbController.dart';
import 'package:bruh/firebaseController/userDbController.dart';
import 'package:bruh/helper/SharedPreference.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:random_string/random_string.dart';
import 'package:readmore/readmore.dart';

class MasterFunction {
  late String myuid, chatRoomId;
  late DocumentReference reference;
  String? messageId;
  TextEditingController messagecontroller = TextEditingController();
  final userController = Get.put(UserRepository());
  final chatroomController = Get.put(RandomChatRoomRepository());

  addMessage(bool sendClicked) {
    if (messagecontroller.text != "") {
      String message = messagecontroller.text;
      messagecontroller.text = "";
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(now);
      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myuid,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
      };
      messageId ??= randomAlphaNumeric(20);
      chatroomController.addMessage(chatRoomId, messageId!, messageInfoMap);
    }
  }
}

class RandomChatPage extends StatefulWidget {
  const RandomChatPage({super.key});

  @override
  State<RandomChatPage> createState() => _RandomChatPageState();
}

class _RandomChatPageState extends State<RandomChatPage> {
  late MasterFunction master;
  Stream? documentstream;

  onload() async {
    master = MasterFunction();
    master.myuid = SharedPrefs().uid;
    master.chatRoomId = await getChatRoomId();
    documentstream =
        await master.chatroomController.getDocumentStream(master.chatRoomId);
    setState(() {});
  }

  deleteroom() async {
    await master.reference.delete();
  }

  getChatRoomId() async {
    final id = await master.chatroomController.lookForRooms();
    master.reference = id;
    await master.chatroomController.getDocument(id.id);
    await FirebaseFirestore.instance
        .collection('randomchatrooms')
        .doc(id.id)
        .update({
      'userscount': FieldValue.increment(1),
    });
    return id.id;
  }

  Query<Map<String, dynamic>> getQuery() {
    final FirebaseFirestore _db = FirebaseFirestore.instance;
    Query<Map<String, dynamic>> query = _db
        .collection('randomchatrooms')
        .doc(master.chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true);
    return query;
  }

  Widget chatElements() {
    return Stack(
      children: [
        Container(child: chatMessage()),
        Container(
          margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
          alignment: Alignment.bottomCenter,
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: TextField(
                minLines: 1,
                maxLines: 4,
                controller: master.messagecontroller,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Type a message",
                    hintStyle: const TextStyle(color: Colors.black45),
                    suffixIcon: GestureDetector(
                        onTap: () {
                          master.addMessage(true);
                        },
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.black,
                        ))),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget chatMessage() {
    return FirestoreListView<Map<String, dynamic>>(
      padding: const EdgeInsets.only(bottom: 100.0, top: 10),
      reverse: true,
      query: getQuery(),
      itemBuilder: (context, doc) {
        final ds = doc.data();
        return chatMessageTile(ds["message"], master.myuid == ds["sendBy"]);
      },
      loadingBuilder: (context) {
        return const LinearProgressIndicator(
          backgroundColor: Colors.white,
          color: Colors.black,
        );
      },
    );
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

  @override
  void initState() {
    super.initState();
    onload();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> backButton() async {
      return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text('Do you want to leave the chat'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () async {
                    await deleteroom();
                    Navigator.of(context).pop(true);
                    Navigator.pop(context);
                  },
                  child: const Text('Yes'),
                ),
              ],
            ),
          )) ??
          false;
    }

    return WillPopScope(
      onWillPop: backButton,
      child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Stranger",
              style: TextStyle(
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
              onPressed: () async {
                await backButton();
              },
            ),
            actions: [
              ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () async {
                    await deleteroom();
                    onload();
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
          body: StreamBuilder(
              stream: documentstream,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data;
                  if (!data.exists) {
                    return const Center(
                      child: Text(
                        'User has left the chat',
                        style: TextStyle(fontFamily: 'Mulish'),
                      ),
                    );
                  } else if (data['userscount'] == 1) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LoadingAnimationWidget.threeRotatingDots(
                              color: Colors.black, size: 50.0),
                          const SizedBox(
                            height: 20.0,
                          ),
                          const Text(
                            'Waiting for Stranger',
                            style: TextStyle(fontFamily: 'Mulish'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return chatElements();
                  }
                }
                return Container();
              })),
    );
  }
}
