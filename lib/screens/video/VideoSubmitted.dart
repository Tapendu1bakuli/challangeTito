import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/screens/dashboard/HomeScreen.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/localStorage.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoSubmitted extends StatefulWidget {
  @override
  VideoSubmittedState createState() => VideoSubmittedState();
}

class VideoSubmittedState extends State<VideoSubmitted> {
  TextEditingController textEditingController = TextEditingController();

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();
  String youtubelink = "XXXXXXXXXXXXXXXXXXXXX";

  @override
  void initState() {
    getlink();
    super.initState();
  }

  getlink() async {
    var localStorage = new LocalHiveStorage();
    youtubelink = await localStorage.getValue("youtubelink");

    if (youtubelink.isEmpty) youtubelink = "XXXXXXXXXXXXXXXXXXXXX";

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => goAuth(),
      child: Scaffold(
        backgroundColor: CustomColor.myCustomYellow,
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(alignment: Alignment.center, children: [
              ListView(
                children: <Widget>[
                  SizedBox(height: 30),
                  Container(
                    height: MediaQuery.of(context).size.height / 4,
                    width: MediaQuery.of(context).size.width / 1.5,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/logo.png"),
                        // fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      AppString.submitSuccess.tr,
                      style: TextStyle(fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 8),
                    child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: AppString.subscribe_youtube.tr,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontSize: 15),
                        )),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 8),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: youtubelink,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () {
                            launch(youtubelink);
                          },
                      ),
                    ),
                  ),
                  /*   SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 8),
                    child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: AppString.win_videos,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontSize: 15),
                        )),
                  ), */
                ],
              ),
              Positioned(
                child: Align(
                  child: SafeArea(
                      child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 30),
                    child: ButtonTheme(
                      height: 50,
                      child: TextButton(
                        onPressed: () {
                          //print(youtubelink);
                          goAuth();
                        },
                        child: Center(
                            child: Text(
                          AppString.close.tr.toUpperCase(),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: CustomColor.myCustomYellow,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.black),
                    ),
                  )),
                  alignment: Alignment.center,
                ),
                bottom: 5,
              )
            ])),
      ),
    );
  }

  goAuth() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (Route<dynamic> route) => false);
  }
}
