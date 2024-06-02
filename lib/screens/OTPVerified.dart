import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';

class OTPVerified extends StatefulWidget {
  final String? email;

  OTPVerified({this.email});

  @override
  OTPVerifiedScreenState createState() => OTPVerifiedScreenState();
}

class OTPVerifiedScreenState extends State<OTPVerified> {
  TextEditingController textEditingController = TextEditingController();

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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
        body: GestureDetector(
          onTap: () {},
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  child: ClipOval(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.black,
                      size: 80,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppString.verified.tr,
                    style: TextStyle(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                  child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: AppString.account_verified.tr,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      )),
                ),
                SizedBox(
                  height: 14,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 30),
                  child: ButtonTheme(
                    height: 50,
                    child: TextButton(
                      onPressed: () {
                        goAuth();
                      },
                      child: Center(
                          child: Text(
                        AppString.login.tr,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: CustomColor.myCustomBlack,
                    borderRadius: BorderRadius.circular(5),
                    /* boxShadow: [
                        BoxShadow(
                            color: CustomColor.myCustomBlack,
                            offset: Offset(1, -2),
                            blurRadius: 6),
                        BoxShadow(
                            color: CustomColor.myCustomBlack,
                            offset: Offset(-1, 2),
                            blurRadius: 6)
                      ], */
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  goAuth() {
    Navigator.pushNamedAndRemoveUntil(
        context, '/Login', (Route<dynamic> route) => false);
  }
}
