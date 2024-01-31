// ignore_for_file: prefer_const_constructors, unnecessary_cast, camel_case_types

import 'dart:typed_data';

import 'package:bruh/pages/General/Person.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class searchPeople extends StatefulWidget {
  const searchPeople({super.key});

  @override
  State<searchPeople> createState() => _searchPeopleState();
}

void refresh() {}

class _searchPeopleState extends State<searchPeople> {
  String name = "";

  Widget _search() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: TextStyle(color: Colors.white),
        prefixIcon: Icon(
          Icons.search,
          color: Colors.white,
        ),
        border: OutlineInputBorder(borderSide: BorderSide.none),
      ),
      style: TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      onChanged: (value) {
        setState(() {
          name = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: _search(),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshots) {
                  return (snapshots.connectionState == ConnectionState.waiting
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Expanded(
                          child: SizedBox(
                            height: 200.0,
                            child: ListView.builder(
                              itemCount: snapshots.data!.docs.length,
                              itemBuilder: (context, index) {
                                var data = snapshots.data!.docs[index].data()
                                    as Map<String, dynamic>;
                                if (name.isEmpty) {
                                  return ListTile(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Person(uid: data['uid'])));
                                    },
                                    title: Text(
                                      data['name'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontFamily: 'Mulish',
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800),
                                    ),
                                    subtitle: Text(data['registernumber'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        )),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(120),
                                      child: Image.memory(
                                        Uint8List.fromList(
                                            data['profile'].codeUnits),
                                        height: 40.0,
                                      ),
                                    ),
                                  );
                                }
                                if (data["name"]
                                    .toString()
                                    .toLowerCase()
                                    .contains(name.toLowerCase())) {
                                  return ListTile(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Person(uid: data['uid'])));
                                    },
                                    title: Text(
                                      data['name'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(data['registernumber'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        )),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(120),
                                      child: Image.memory(
                                        Uint8List.fromList(
                                            data['profile'].codeUnits),
                                        height: 50.0,
                                      ),
                                    ),
                                  );
                                }
                                return Container();
                              },
                            ),
                          ),
                        ));
                })
          ],
        ),
      ),
    );
  }
}
