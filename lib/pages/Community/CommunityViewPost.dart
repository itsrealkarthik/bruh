import 'dart:typed_data';

import 'package:bruh/firebaseController/communityDbController.dart';
import 'package:bruh/helper/SharedPreference.dart';
import 'package:bruh/pages/General/Person.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:readmore/readmore.dart';

class MessageBubble {
  final String uid;
  final String name;
  final String registernumber;
  final String profile;
  final String message;

  const MessageBubble({
    required this.uid,
    required this.name,
    required this.registernumber,
    required this.profile,
    required this.message,
  });
}

class Post {
  final String title;
  final String query;
  final String registernumber;

  const Post({
    required this.title,
    required this.query,
    required this.registernumber,
  });
}

class CommunityViewPost extends StatefulWidget {
  const CommunityViewPost(
      {super.key,
      required this.uid,
      required this.profile,
      required this.name,
      required this.registernumber,
      required this.reference,
      required this.title,
      required this.query});
  final String uid;
  final String profile, name, registernumber, title, query;
  final DocumentReference reference;

  @override
  State<CommunityViewPost> createState() => _CommunityViewPostState();
}

class _CommunityViewPostState extends State<CommunityViewPost> {
  late final String uid, profile, name, registernumber, title, query;
  late final String reference;
  String myuid = SharedPrefs().uid;
  final TextEditingController messagecontroller = TextEditingController();
  final communityController = Get.put(CommunityRepository());
  List<MessageBubble> list = [];

  addMessage(bool sendClicked) {
    String? messageId;
    if (messagecontroller.text != "") {
      String message = messagecontroller.text;
      messagecontroller.text = "";
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(now);
      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myuid,
        "name": SharedPrefs().name,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
      };
      messageId ??= randomAlphaNumeric(20);
      communityController.addMessage(reference, messageId, messageInfoMap);
    }
  }

  @override
  void initState() {
    super.initState();
    uid = widget.uid;
    profile = widget.profile;
    reference = widget.reference.id;
    name = widget.name;
    title = widget.title;
    query = widget.query;
    registernumber = widget.registernumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          "Post",
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Mulish',
              fontWeight: FontWeight.w700),
        ),
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          child: Column(children: [
            Container(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Person(uid: uid),
                          ));
                    },
                    child: Row(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.memory(
                              Uint8List.fromList(widget.profile.codeUnits),
                              height: 30.0,
                              fit: BoxFit.cover,
                            )),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          widget.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Mulish'),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          widget.registernumber,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30.0,
                            fontWeight: FontWeight.w800),
                      )),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.query,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      )),
                  const SizedBox(
                    height: 20.0,
                  )
                ]),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            ChatPart(postid: reference),
          ]),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
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
                controller: messagecontroller,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Type a message",
                    hintStyle: const TextStyle(color: Colors.black45),
                    suffixIcon: GestureDetector(
                        onTap: () {
                          addMessage(true);
                        },
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.black,
                        ))),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class ChatPart extends StatefulWidget {
  const ChatPart({super.key, required this.postid});
  final String postid;

  @override
  State<ChatPart> createState() => _ChatPartState();
}

class _ChatPartState extends State<ChatPart> {
  Stream? messagestream;
  late final String postid;

  onload() async {
    postid = widget.postid;
    final communityController = Get.put(CommunityRepository());
    messagestream = await communityController.getChatRoomMessages(postid);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    onload();
  }

  Widget chatMessageTile(String message, bool sendByMe, String name) {
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
              Text(
                name,
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
              ),
              const SizedBox(
                height: 2,
              ),
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
  Widget build(BuildContext context) {
    String myuid = SharedPrefs().uid;
    return StreamBuilder(
        stream: messagestream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 110.0, top: 0),
                  itemCount: snapshot.data.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return chatMessageTile(
                        ds["message"], myuid == ds["sendBy"], ds['name']);
                  })
              : const Center(
                  child: CircularProgressIndicator(),
                );
        });
  }
}
