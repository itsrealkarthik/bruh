import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequestRepo {
  final String senderuid;
  final String receiveruid;
  final String time;
  final List<String> participants;

  const FriendRequestRepo({
    required this.senderuid,
    required this.receiveruid,
    required this.time,
    required this.participants,
  });

  toJson() {
    return {
      "senderuid": senderuid,
      "receiveruid": receiveruid,
      "time": time,
      "participants": participants,
    };
  }

  factory FriendRequestRepo.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;

    return FriendRequestRepo(
        senderuid: data["senderuid"],
        receiveruid: data['receiveruid'],
        time: data['time'],
        participants: data['participants']);
  }
}
