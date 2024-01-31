import 'dart:typed_data';

import 'package:bruh/firebaseController/userDbController.dart';
import 'package:bruh/helper/SharedPreference.dart';
import 'package:bruh/pages/Community/CommunityCreatePost.dart';
import 'package:bruh/pages/Community/CommunityViewPost.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:bruh/firebaseController/communityDbController.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommunityPost {
  final DocumentReference postid;
  final String uid;
  final String title;
  final String query;
  final String profile;
  final String registernumber;
  final String name;

  CommunityPost({
    required this.postid,
    required this.uid,
    required this.title,
    required this.query,
    required this.profile,
    required this.registernumber,
    required this.name,
  });
}

class Community extends StatefulWidget {
  const Community({super.key});
  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  late CommunityRepository communityController;
  late UserRepository userController;

  @override
  void initState() {
    super.initState();
    Get.delete<CommunityRepository>();
    Get.delete<UserRepository>();

    communityController = Get.put(CommunityRepository());
    userController = Get.put(UserRepository());
  }

  Query<Map<String, dynamic>> fetchPost() {
    final query = communityController.fetchPosts();
    return query;
  }

  deletePost(DocumentReference postid) async {
    await postid.delete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final myuid = SharedPrefs().uid;
    return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
              child: Text(
                'Posts',
                style: TextStyle(
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w800,
                    fontSize: 25.0),
              ),
            ),
            Expanded(
              child: FirestoreListView<Map<String, dynamic>>(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                query: fetchPost(),
                itemBuilder: (context, doc) {
                  final post = doc.data();
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CommunityViewPost(
                                      uid: post['uid'],
                                      profile: post['profile'],
                                      reference: doc.reference,
                                      name: post['name'],
                                      registernumber: post['registernumber'],
                                      title: post['title'],
                                      query: post['query'],
                                    )));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 10.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(120),
                                    child: Image.memory(
                                      Uint8List.fromList(
                                          post['profile'].codeUnits),
                                      height: 30,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    post['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(post['registernumber']),
                                  const Spacer(),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      post['time'],
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  if (post['uid'] == myuid)
                                    GestureDetector(
                                        onTap: () {
                                          deletePost(doc.reference);
                                        },
                                        child: const Icon(
                                          Icons.delete,
                                          size: 20,
                                        )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post['title'],
                                    style: const TextStyle(
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.w800),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  Text(
                                    post['query'],
                                    style: const TextStyle(fontSize: 15.0),
                                    overflow: TextOverflow.fade,
                                    maxLines: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                loadingBuilder: (context) {
                  return Center(
                    child: LoadingAnimationWidget.threeRotatingDots(
                        color: Colors.black, size: 50.0),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CommunityCreatePost()),
              );
            },
            child: const Icon(Icons.create)));
  }
}
