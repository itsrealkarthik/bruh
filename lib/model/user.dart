import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepo {
  final String uid;
  final String registernumber;
  final String name;
  final String gender;
  final String nativestate;
  final String hosteller;
  final String profile;
  final List friends;
  final List classes;

  const UserRepo({
    required this.uid,
    required this.registernumber,
    required this.name,
    required this.gender,
    required this.nativestate,
    required this.hosteller,
    required this.profile,
    required this.friends,
    required this.classes,
  });

  toJson() {
    return {
      "uid": uid,
      "registernumber": registernumber,
      "name": name,
      "gender": gender,
      "nativestate": nativestate,
      "hosteller": hosteller,
      "profile": profile,
      "friends": friends,
      "classes": classes,
    };
  }

  factory UserRepo.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;

    return UserRepo(
      uid: data["uid"],
      registernumber: data["registernumber"],
      name: data["name"],
      gender: data["gender"],
      nativestate: data["nativestate"],
      hosteller: data["hosteller"],
      profile: data["profile"],
      friends: (data["friends"] as List).cast<String>(),
      classes: (data["classes"] as List).cast<String>(),
    );
  }
}
