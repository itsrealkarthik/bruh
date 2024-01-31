// ignore_for_file: unused_catch_clause

import 'dart:convert';
import 'dart:typed_data';

import 'package:bruh/helper/SharedPreference.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bruh/model/user.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<String> getCurrentUser() async {
    final User? fireBaseUser = _auth.currentUser;
    final myuid = fireBaseUser!.uid;
    return myuid;
  }

  createUser(UserRepo user) async {
    await _db
        .collection("users")
        .add(user.toJson())
        .whenComplete(() => debugPrint("User Added Successfully"))
        // ignore: body_might_complete_normally_catch_error
        .catchError((onError) {
      debugPrint(onError.toString());
    });
  }

  Future<void> createFirebaseUser(String jsonString) async {
    Map<String, dynamic> user = json.decode(jsonString);
    String encodedImage = user['profile'];
    String base64Captcha = encodedImage.split(',')[1];
    Uint8List decodedBytes =
        base64.decode(base64Captcha.replaceAll(RegExp(r'[^a-zA-Z0-9+/=]'), ''));
    user['profile'] = String.fromCharCodes(decodedBytes);

    try {
      await _auth.createUserWithEmailAndPassword(
          email: user['registernumber'] + '@vitstudent.ac.in',
          password: user['registernumber']);

      final userController = Get.put(UserRepository());
      final newUser = UserRepo(
          uid: await getCurrentUser(),
          registernumber: user['registernumber'],
          name: user['name'],
          gender: user['gender'],
          nativestate: user['nativestate'],
          hosteller: user['hosteller'],
          profile: user['profile'],
          friends: [],
          classes: []);

      await userController.createUser(newUser);
      await loginFirebaseUser(user);
    } on FirebaseException catch (e) {
      await loginFirebaseUser(user);
    }
  }

  Future<UserRepo> getUserDetails(String uid) async {
    final snapshot =
        await _db.collection("users").where("uid", isEqualTo: uid).get();
    final userData = snapshot.docs.map((e) => UserRepo.fromSnapshot(e)).single;
    return userData;
  }

  Future<Query<Map<String, dynamic>>> getUserDetailsReference(
      String uid) async {
    final reference = _db.collection("users").where("uid", isEqualTo: uid);
    return reference;
  }

  Future<void> loginFirebaseUser(Map<String, dynamic> user) async {
    await _auth.signInWithEmailAndPassword(
        email: user['registernumber'] + '@vitstudent.ac.in',
        password: user['registernumber']);
    await setSharedPreference(user);
  }

  setSharedPreference(Map<String, dynamic> user) async {
    SharedPrefs().uid = await getCurrentUser();
    SharedPrefs().name = user['name'];
    SharedPrefs().registernumber = user['registernumber'];
    SharedPrefs().profile = user['profile'];
    SharedPrefs().gender = user['gender'];
    SharedPrefs().hosteller = user['hosteller'];
    SharedPrefs().nativestate = user['nativestate'];
  }

  Future<void> setClasses(String jsonString) async {
    String myuid = FirebaseAuth.instance.currentUser!.uid;
    List<String> classes = [];
    Map<String, dynamic> courses = json.decode(jsonString);
    List course = courses['courses'];
    for (var cls in course) {
      String classnumber = cls['number'];
      classes.add(classnumber);
    }
    SharedPrefs().classes = classes;
    Query<Map<String, dynamic>> documentReference =
        await getUserDetailsReference(myuid);

    final data = await documentReference.get();
    data.docs.last.reference.update({'classes': classes});
  }
}
