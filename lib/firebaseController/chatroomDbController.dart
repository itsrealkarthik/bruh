import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ChatRoomRepository extends GetxController {
  static ChatRoomRepository get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String currentuid = FirebaseAuth.instance.currentUser!.uid;

  createChatRoom(String chatroomid, Map<String, dynamic> users) async {
    final snapshot = await _db.collection("chatrooms").doc(chatroomid).get();
    if (snapshot.exists) {
      return true;
    } else {
      return _db.collection("chatrooms").doc(chatroomid).set(users);
    }
  }

  Future addMessage(String chatRoomId, String messageId,
      Map<String, dynamic> messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  updateLastMessageSend(
      String chatRoomId, Map<String, dynamic> lastMessageInfoMap) {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .orderBy("time", descending: true)
        .where("users", arrayContains: currentuid)
        .snapshots();
  }
}
