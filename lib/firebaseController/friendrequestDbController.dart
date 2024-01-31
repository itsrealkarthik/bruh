import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:bruh/model/friendrequest.dart';

class FriendRequestRepository extends GetxController {
  static FriendRequestRepository get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  createfriendrequest(FriendRequestRepo request) async {
    await _db
        .collection("friendrequests")
        .add(request.toJson())
        .whenComplete(() => debugPrint("Post Added Successfully"));
  }

  Future<QuerySnapshot<Map<String, dynamic>>> friendrequestexists(
      String senderuid, String receiveruid) async {
    var ref = await _db
        .collection("friendrequests")
        .where(Filter.or(
            Filter.and(Filter("senderuid", isEqualTo: senderuid),
                Filter("receiveruid", isEqualTo: receiveruid)),
            Filter.and(Filter("senderuid", isEqualTo: receiveruid),
                Filter("receiveruid", isEqualTo: senderuid))))
        .get()
        .catchError((onError) {
      debugPrint(onError.toString());
    });

    return ref;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getallfriendrequests(
      String uid) async {
    QuerySnapshot<Map<String, dynamic>> requests = await _db
        .collection("friendrequests")
        .where("receiveruid", isEqualTo: uid)
        .get();
    return requests;
  }
}
