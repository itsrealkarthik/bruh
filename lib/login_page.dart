// ignore_for_file: unused_local_variable

import 'package:bruh/homepage_page.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';

import 'dart:convert';
import 'dart:typed_data';

import './firebaseController/userDbController.dart';

class MasterFuntion {
  // ignore: constant_identifier_names
  static const VTOP_URL = 'https://vtopcc.vit.ac.in/vtop/';
  late WebViewController _controller;
  final WebViewCookieManager cookieManager = WebViewCookieManager();
  final TextEditingController _usernamecontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final TextEditingController _captchacontroller = TextEditingController();

  late BuildContext context;
  //******************************************************************************//

  MasterFuntion() {
    cookieManager.clearCookies();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..clearCache()
      ..addJavaScriptChannel('receiveDetails', onMessageReceived: (message) {
        firebaseAuth(message.message);
      })
      ..addJavaScriptChannel('receiveError', onMessageReceived: (message) {
        print(message.message);
      })
      ..setNavigationDelegate(NavigationDelegate(
        onWebResourceError: (error) {
          print(error);
        },
      ));
  }

  Future<void> openSignIn(BuildContext context) async {
    this.context = context;
    int count = 0;
    await _controller.loadRequest(Uri.parse(VTOP_URL));
    await _controller.setNavigationDelegate(NavigationDelegate(
      onPageFinished: (url) async {
        _controller.runJavaScript("""
                try{
                  document.querySelector('#stdForm').submit();
                }
                catch(e){
                  receiveError.postMessage("Retry after a few seconds");
                }
                """);

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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Captcha'),
            content: SizedBox(
              height: 100.0,
              child: Column(
                children: [
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
                  Navigator.of(context, rootNavigator: true).pop();
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
              catch(e){
                receiveError.postMessage("Error in getting captcha");
              }
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
    } else {
      await _controller.runJavaScript("""
      document.querySelector('#vtopLoginForm [name="username"]').value = "$username";
      document.querySelector('#vtopLoginForm [name="password"]').value = "$password";
      document.querySelector('#vtopLoginForm').submit();""");
    }

    await _controller.setNavigationDelegate(NavigationDelegate(
      onPageFinished: (url) async {
        await _controller.runJavaScript("""
        (function() {
        var data = 'verifyMenu=true&authorizedID=' + \$('#authorizedIDX').val() + '&_csrf=' + \$('input[name="_csrf"]').val() + '&nocache=@(new Date().getTime())';
        var response = {};
        \$.ajax({
            type: 'POST',
            url: 'studentsRecord/StudentProfileAllView',
            data: data,
            async: false,
            success: function(res) {
                if (res.toLowerCase().includes('personal information')) {
                    var doc = new DOMParser().parseFromString(res, 'text/html');
                    var cells = doc.getElementsByTagName('td');
                    for (var i = 0; i < cells.length; ++i) {
                        var key = cells[i].innerText.toLowerCase();
                        for (var i = 0; i < cells.length; ++i) {
                          var key = cells[i].innerText.toLowerCase();
                          if(key.includes('application') && key.includes('number')){
                            response.profile = cells[i + 2].querySelector('img').src;
                          }
                          if (key.includes('student') && key.includes('name')) {
                            response.name = cells[++i].innerHTML;
                          }
                          if (key.includes('gender')) {
                            response.gender = cells[++i].innerHTML;
                          }
                          if (key.includes('native') && key.includes('state')) {
                            response.nativestate = cells[++i].innerHTML;
                          }
                          if (key.includes('hosteller')) {
                            response.hosteller = cells[++i].innerHTML;
                          }
                          if (key.includes('vit') && key.includes('register')&& key.includes('number')) {
                            response.registernumber = cells[++i].innerHTML;
                          }
                        }
                        receiveDetails.postMessage(JSON.stringify(response));
                    }
                }
            }
        });
    })();

          """);
      },
    ));
  }

  Future<void> firebaseAuth(String jsonString) async {
    final userController = Get.put(UserRepository());
    await userController.createFirebaseUser(jsonString);
    moveToNextPage();
  }

  void moveToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const String id = 'login';
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return Scaffold(
      body: const LoginPageWidget(),
    );
  }
}

class LoginPageWidget extends StatelessWidget {
  const LoginPageWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final MasterFuntion master = MasterFuntion();
    return SafeArea(
        child: SingleChildScrollView(
      child: Column(
        children: [
          Visibility(
              visible: true,
              maintainState: true,
              child: SizedBox(
                height: 200,
                child: WebViewWidget(controller: master._controller),
              )),
          const SizedBox(
            height: 50.0,
          ),
          Image.asset(
            'assets/images/logo.png',
            width: 200.0,
            height: 200.0,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Login',
                  style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 30.0,
                      fontWeight: FontWeight.w700),
                )),
          ),
          const SizedBox(
            height: 25.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                hintText: 'Username',
              ),
              controller: master._usernamecontroller,
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                hintText: 'Password',
              ),
              controller: master._passwordcontroller,
            ),
          ),
          const SizedBox(
            height: 50.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 3.0, color: Colors.white),
                  backgroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(70),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0))),
              onPressed: () async {
                await master.openSignIn(context);
              },
              child: const Text(
                'Get Captcha',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontFamily: "Mulish",
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
