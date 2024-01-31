import 'dart:math';

import 'package:bruh/helper/SharedPreference.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class RandomChatRoomRepository extends GetxController {
  static RandomChatRoomRepository get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String myuid = SharedPrefs().uid;

  Future<DocumentReference> lookForRooms() async {
    late DocumentReference ids;
    final snapshot = await _db
        .collection("randomchatrooms")
        .where('userscount', isEqualTo: 1)
        .get();
    if (snapshot.size > 0) {
      var len = snapshot.size;
      Random random = Random();
      int randomNumber = random.nextInt(len);
      ids = snapshot.docs[randomNumber].reference;
    } else {
      final id = await createChatRoom();
      ids = id;
    }
    return ids;
  }

  Future<DocumentReference> createChatRoom() async {
    final count = {'userscount': 0};
    late DocumentReference id;
    await _db.collection("randomchatrooms").add(count).then((value) {
      id = value;
    });
    return id;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(String id) async {
    return await _db.collection('randomchatrooms').doc(id).get();
  }

  Future addMessage(String chatRoomId, String messageId,
      Map<String, dynamic> messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("randomchatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  updateLastMessageSend(
      String chatRoomId, Map<String, dynamic> lastMessageInfoMap) {
    return FirebaseFirestore.instance
        .collection("randomchatrooms")
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("randomchatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    return FirebaseFirestore.instance
        .collection("randomchatrooms")
        .orderBy("time", descending: true)
        .where("users", arrayContains: myuid)
        .snapshots();
  }

  Future<Stream<DocumentSnapshot>> getDocumentStream(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("randomchatrooms")
        .doc(chatRoomId)
        .snapshots();
  }
}
