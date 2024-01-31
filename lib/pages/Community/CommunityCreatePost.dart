import 'package:bruh/firebaseController/communityDbController.dart';
import 'package:bruh/helper/SharedPreference.dart';
import 'package:bruh/model/community.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CommunityCreatePost extends StatefulWidget {
  const CommunityCreatePost({super.key});

  @override
  State<CommunityCreatePost> createState() => _CommunityCreatePostState();
}

Future<void> postQuery(String title, String query) async {
  final communityController = Get.put(CommunityRepository());
  var timestamp = DateTime.now();
  String formattedDate = DateFormat('d MMM y kk:mm').format(timestamp);

  CommunityRepo post = CommunityRepo(
      uid: SharedPrefs().uid,
      registernumber: SharedPrefs().registernumber,
      name: SharedPrefs().name,
      profile: SharedPrefs().profile,
      title: title,
      query: query,
      time: formattedDate);
  await communityController.createPost(post);
}

class _CommunityCreatePostState extends State<CommunityCreatePost> {
  final TextEditingController _titlecontroller = TextEditingController();
  final TextEditingController _querycontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Create a post",
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Mulish',
              fontWeight: FontWeight.w700),
        ),
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: 80.0,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10.0,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  maxLength: 50,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Title',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 30.0,
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    )),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    )),
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 30.0,
                  ),
                  controller: _titlecontroller,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  maxLength: 250,
                  minLines: 10,
                  maxLines: null,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type your query',
                      hintStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      )),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)))),
                  controller: _querycontroller,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50.0),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white),
                    child: const Text('Post'),
                    onPressed: () async {
                      await postQuery(
                          _titlecontroller.text, _querycontroller.text);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
