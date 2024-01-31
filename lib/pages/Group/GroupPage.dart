// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:typed_data';

import 'package:bruh/firebaseController/groupDbController.dart';
import 'package:bruh/firebaseController/userDbController.dart';
import 'package:bruh/helper/Loading.dart';
import 'package:bruh/pages/Group/GroupChatPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MasterFuntion {
  // ignore: constant_identifier_names
  static const VTOP_URL = 'https://vtopcc.vit.ac.in/vtop/';
  late WebViewController _controller;
  final WebViewCookieManager cookieManager = WebViewCookieManager();
  final TextEditingController _usernamecontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final TextEditingController _captchacontroller = TextEditingController();

  int count = 0;

  late BuildContext context;
  //******************************************************************************//

  MasterFuntion() {
    cookieManager.clearCookies();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..clearCache()
      ..addJavaScriptChannel('receiveSemesters', onMessageReceived: (message) {
        count++;
        if (count == 2) {
          Map<String, dynamic> semester = json.decode(message.message);
          showSemesterList(semester);
          count = 0;
        }
      })
      ..addJavaScriptChannel('receiveClass', onMessageReceived: (message) {
        firebaseAuth(message.message);
      });
  }

  Future<void> openSignIn(BuildContext context) async {
    this.context = context;
    int count = 0;
    await _controller.loadRequest(Uri.parse(VTOP_URL));
    await _controller.setNavigationDelegate(NavigationDelegate(
      onPageFinished: (url) async {
        if (url.contains('/page')) {
          await _controller.runJavaScript("""
                try{
                  document.querySelector('#stdForm').submit();
                }
                catch(e){}
                """);
        }
        await _controller.setNavigationDelegate(NavigationDelegate(
          onPageFinished: (url) {
            count += 1;
            if (url.contains('/login') && count == 2) {
              getCaptcha(context);
            }
          },
        ));
      },
    ));
  }

  Future<void> showCaptcha(String encodedImage, BuildContext context) async {
    String base64Captcha = encodedImage.split(',')[1];
    Uint8List decodedBytes =
        base64.decode(base64Captcha.replaceAll(RegExp(r'[^a-zA-Z0-9+/=]'), ''));
    if (decodedBytes.isNotEmpty) {
      Image captchaImage = Image.memory(decodedBytes);
      Navigator.of(context, rootNavigator: true).pop();
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login'),
            content: SizedBox(
              height: 250.0,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter username',
                    ),
                    controller: _usernamecontroller,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter password',
                    ),
                    controller: _passwordcontroller,
                  ),
                  captchaImage,
                  TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter captcha',
                    ),
                    controller: _captchacontroller,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  signIn(1);
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                          content: SizedBox(
                        height: 50,
                        child: load(),
                      ));
                    },
                  );
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> getCaptcha(BuildContext context) async {
    var imageData = await _controller.runJavaScriptReturningResult("""
              try{
                document.getElementById('captchaBlock').querySelector('img').getAttribute('src');
              }
              catch(e){}
              """);
    if (imageData as String != "null") {
      if (!context.mounted) return;
      showCaptcha(imageData, context);
    } else {
      await _controller.runJavaScript("""
  function callBuiltValidation(token) { 
    if (typeof captchaInterval != 'undefined') clearInterval(captchaInterval);
    if (typeof captchaInterval != 'undefined') clearInterval(captchaInterval);
    document.querySelector('#vtopLoginForm [name="username"]').value = "21BCE5481";
      document.querySelector('#vtopLoginForm [name="password"]').value = "Raji*714300";
      document.querySelector('#vtopLoginForm').submit(); }
  (function() {
      var executeInterval = setInterval(function() {
        try {
          if (typeof grecaptcha !== 'undefined') {
          grecaptcha.execute();
          clearInterval(executeInterval);
          }
        } catch (err) {
      }
      }, 500);})();
      """);
    }
  }

  Future<void> signIn(int type) async {
    String username = _usernamecontroller.text;
    String password = _passwordcontroller.text;
    if (type == 1) {
      String captcha = _captchacontroller.text;
      await _controller.runJavaScript("""
      document.querySelector('#vtopLoginForm [name="username"]').value = "$username";
      document.querySelector('#vtopLoginForm [name="password"]').value = "$password";
      document.querySelector('#vtopLoginForm [name="captchaStr"]').value = "$captcha";
      document.querySelector('#vtopLoginForm').submit();""");
      await _controller.setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          goToTargetPage();
        },
      ));
    } else {
      await _controller.runJavaScript("""
      document.querySelector('#vtopLoginForm [name="username"]').value = "$username";
      document.querySelector('#vtopLoginForm [name="password"]').value = "$password";
      document.querySelector('#vtopLoginForm').submit();""");
    }
  }

  Future<void> goToTargetPage() async {
    await _controller.runJavaScript("window.onload = (function() {" +
        "var data = 'verifyMenu=true&authorizedID=' + \$('#authorizedIDX').val() + '&_csrf=' + \$('input[name=\"_csrf\"]').val() + '&nocache=@(new Date().getTime())';" +
        "var response = {};" +
        "\$.ajax({" +
        "    type: 'POST'," +
        "    url : 'academics/common/StudentTimeTable'," +
        "    data : data," +
        "    async: false," +
        "    success: function(res) {" +
        "        if(res.toLowerCase().includes('time table')) {" +
        "            var doc = new DOMParser().parseFromString(res, 'text/html');" +
        "            var options = doc.getElementById('semesterSubId').getElementsByTagName('option');" +
        "            var semesters = [];" +
        "            for(var i = 0; i < options.length; ++i) {" +
        "                if(!options[i].value) {" +
        "                    continue;" +
        "                }" +
        "                var semester = {" +
        "                    name: options[i].innerText," +
        "                    id: options[i].value" +
        "                };" +
        "                semesters.push(semester);" +
        "            }" +
        "            response.semesters = semesters;" +
        "        }" +
        "    }" +
        "});" +
        "receiveSemesters.postMessage(JSON.stringify(response));" +
        "})();");
  }

  showSemesterList(Map<String, dynamic> semester) {
    String? newvalue;
    List<Map<dynamic, dynamic>> semesters =
        (semester['semesters'] as List<dynamic>)
            .map((semester) => semester as Map<dynamic, dynamic>)
            .toList();
    Navigator.of(context, rootNavigator: true).pop();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Semester'),
          content: DropdownButton<String>(
            hint: const Text('Choose'),
            isDense: true,
            value: newvalue,
            items: semesters.map((Map map) {
              return DropdownMenuItem<String>(
                value: map["id"].toString(),
                child: Text(
                  map["name"],
                ),
              );
            }).toList(),
            onChanged: (value) {
              getJSONDetails(value!);
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        );
      },
    );
  }

  Future<void> getJSONDetails(String semesterID) async {
    await _controller.runJavaScript("(function() {" +
        "var data = '_csrf=' + \$('input[name=\"_csrf\"]').val() + '&semesterSubId=' + '" +
        semesterID +
        "' + '&authorizedID=' + \$('#authorizedIDX').val();" +
        "var response = {" +
        "    courses: []" +
        "};" +
        "\$.ajax({" +
        "    type : 'POST'," +
        "    url : 'processViewTimeTable'," +
        "    data : data," +
        "    async: false," +
        "    success : function(res) {" +
        "        var doc = new DOMParser().parseFromString(res, 'text/html');" +
        "        if (!doc.getElementById('studentDetailsList')) {" +
        "            return;" +
        "        }" +
        "        var table = doc.getElementById('studentDetailsList').getElementsByTagName('table')[0];" +
        "        var headings = table.getElementsByTagName('th');" +
        "        var courseIndex, slotVenueIndex, facultyIndex, clsnbrIndex;" +
        "        for(var i = 0; i < headings.length; ++i) {" +
        "            var heading = headings[i].innerText.toLowerCase();" +
        "            if (heading == 'course') {" +
        "                courseIndex = i;" +
        "            } else if (heading.includes('nbr')) {" +
        "                clsnbrIndex = i;" +
        "            } else if (heading.includes('slot')) {" +
        "                slotVenueIndex = i;" +
        "            } else if (heading.includes('faculty')) {" +
        "                facultyIndex = i;" +
        "            }" +
        "        }" +
        "        var cells = table.getElementsByTagName('td');" +
        "        var headingOffset = headings[0].innerText.toLowerCase().includes('invoice') ? -1 : 0;" +
        "        var cellOffset = cells[0].innerText.toLowerCase().includes('invoice') ? 1 : 0;" +
        "        var offset = headingOffset + cellOffset;" +
        "        while (courseIndex < cells.length && slotVenueIndex < cells.length && facultyIndex < cells.length) {" +
        "            var course = {};" +
        "            var rawCourse = cells[courseIndex + offset].innerText.replace(/\\t/g,'').replace(/\\n/g,' ');" +
        "            var rawSlotVenue = cells[slotVenueIndex + offset].innerText.replace(/\\t/g,'').replace(/\\n/g,'').split('-');" +
        "            var rawFaculty = cells[facultyIndex + offset].innerText.replace(/\\t/g,'').replace(/\\n/g,'').split('-');" +
        "            var rawNumber = cells[clsnbrIndex + offset].innerText.replace(/\\t/g,'');" +
        "            course.code = rawCourse.split('-')[0].trim();" +
        "            course.number = rawNumber.trim();" +
        "            course.title = rawCourse.split('-').slice(1).join('-').split('(')[0].trim();" +
        "            course.slots = rawSlotVenue[0].trim().split('+');" +
        "            course.venue = rawSlotVenue.slice(1, rawSlotVenue.length).join(' - ').trim();" +
        "            course.faculty = rawFaculty[0].trim();" +
        "            response.courses.push(course);" +
        "            courseIndex += headings.length + headingOffset;" +
        "            slotVenueIndex += headings.length + headingOffset;" +
        "            facultyIndex += headings.length + headingOffset;" +
        "            clsnbrIndex += headings.length + headingOffset;" +
        "        }" +
        "    }" +
        "});" +
        "receiveClass.postMessage(JSON.stringify(response));" +
        "})();");
  }

  Future<void> firebaseAuth(String jsonString) async {
    final groupController = Get.put(GroupRepository());
    final userController = Get.put(UserRepository());
    await userController.setClasses(jsonString);
    await groupController.getClasses(jsonString);
  }
}

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  MasterFuntion master = MasterFuntion();
  Stream? chatRoomsStream;
  SharedPreferences? sharedPreferences;

  onload() async {
    final groupController = Get.put(GroupRepository());
    sharedPreferences = await SharedPreferences.getInstance();
    chatRoomsStream = await groupController.getChatRooms();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    onload();
  }

  Widget chatRoomList() {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var ds = snapshot.data.docs[index];
                    return ChatTile(
                      number: ds['number'],
                      title: ds['title'],
                      faculty: ds['faculty'],
                      code: ds['code'],
                    );
                  })
              : const Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              Visibility(
                  visible: false,
                  maintainState: true,
                  child: SizedBox(
                    height: 1,
                    child: WebViewWidget(controller: master._controller),
                  )),
              Row(
                children: [
                  const Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Class',
                        style: TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 30,
                            fontWeight: FontWeight.w800),
                      )),
                  const Spacer(),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          minimumSize: const Size(30, 30)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                content: SizedBox(
                              height: 50,
                              child: load(),
                            ));
                          },
                        );
                        master.openSignIn(context);
                      },
                      child: const Text('Join Groups')),
                ],
              ),
              chatRoomList(),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatTile extends StatefulWidget {
  const ChatTile(
      {super.key,
      required this.number,
      required this.title,
      required this.faculty,
      required this.code});
  final String number;
  final String title;
  final String code;
  final String faculty;

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GroupChatPage(
                      code: widget.code,
                      number: widget.number,
                    )));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20.0,
            ),
            ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Icon(IconData(widget.title[0].codeUnitAt(0)))),
            const SizedBox(
              width: 20.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 6.0,
                ),
                Text(
                  widget.title,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 4.0,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Text(
                    widget.code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
