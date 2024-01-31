import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:bruh/model/community.dart';

class CommunityRepository extends GetxController {
  static CommunityRepository get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  DocumentSnapshot? lastDocument;

  Future<DocumentReference> createPost(CommunityRepo user) async {
    final ref = await _db.collection("community").add(user.toJson());
    final message = {"reference": ref.id};
    final snapshot = await _db
        .collection("community")
        .doc(ref.id)
        .collection("chats")
        .doc(ref.id)
        .get();
    if (!snapshot.exists) {
      _db
          .collection("community")
          .doc(ref.id)
          .collection("chats")
          .doc(ref.id)
          .set(message);
    }

    return ref;
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(String postid) async {
    return FirebaseFirestore.instance
        .collection("community")
        .doc(postid)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future addMessage(String postid, String messageId,
      Map<String, dynamic> messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("community")
        .doc(postid)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  fetchPosts() {
    Query query = _db.collection('community').orderBy("time", descending: true);
    return query;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getPost(String docid) async {
    final query = await _db.collection('community').doc(docid).get();
    return query;
  }
}
