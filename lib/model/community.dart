// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityRepo {
  final String profile;
  final String name;
  final String registernumber;
  final String uid;
  final String title;
  final String query;
  final String time;

  CommunityRepo({
    required this.profile,
    required this.name,
    required this.registernumber,
    required this.uid,
    required this.title,
    required this.query,
    required this.time,
  });

  toJson() {
    return {
      "profile": profile,
      "name": name,
      "registernumber": registernumber,
      "uid": uid,
      "title": title,
      "query": query,
      "time": time,
    };
  }

  factory CommunityRepo.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();

    return CommunityRepo(
        name: data['name'],
        profile: data['profile'],
        registernumber: data['registernumber'],
        uid: data['uid'],
        title: data["title"],
        query: data["query"],
        time: data['time']);
  }
}
