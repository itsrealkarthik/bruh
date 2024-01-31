// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:bruh/helper/SharedPreference.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class GroupRepository extends GetxController {
  static GroupRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> getClasses(String jsonString) async {
    Map<String, dynamic> courses = json.decode(jsonString);
    List course = courses['courses'];
    for (var cls in course) {
      if (!await checkIfGroupExists(cls['number'])) {
        _db.collection("groups").doc(cls['number']).set(cls);
      }
    }
  }

  Future<bool> checkIfGroupExists(String classnumber) async {
    try {
      var collection = _db.collection('groups');
      var document = await collection.doc(classnumber).get();
      return document.exists;
    } catch (e) {
      throw e;
    }
  }

  Future addMessage(String number, String messageId,
      Map<String, dynamic> messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("groups")
        .doc(number)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("groups")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    List<String> ids = SharedPrefs().classes;
    return FirebaseFirestore.instance
        .collection("groups")
        .where('number', whereIn: ids)
        .snapshots();
  }

  Future alertHubAddMessage(String number, String messageId,
      Map<String, dynamic> messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("groups")
        .doc(number)
        .collection("alerts")
        .doc(messageId)
        .set(messageInfoMap);
  }

  Future<Stream<QuerySnapshot>> alertHubGetChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("groups")
        .doc(chatRoomId)
        .collection("alerts")
        .orderBy("time", descending: true)
        .snapshots();
  }
}
