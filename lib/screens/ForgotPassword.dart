import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/apiService/AuthServices.dart';
import 'package:titosapp/constants/constants.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/widgets/DefaultEditText.dart';
import 'package:titosapp/widgets/Header.dart';
import 'package:titosapp/widgets/Loader.dart';

import 'OTPScreen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  ForgotPasswordScreenState createState() => new ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailController = TextEditingController();
  AuthService service = new AuthService();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.PRIMARY_COLOR,
        body: Stack(
          children: [
            GestureDetector(
              onTap: () {},
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 30),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      child: Header(),
                    ),
                    SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        AppString.forgot_Password.tr,
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 8),
                      child: RichText(
                        text: TextSpan(
                            children: [
                              TextSpan(
                                  text: AppString.enter_Email_Associated.tr,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ],
                            style:
                                TextStyle(color: Colors.black54, fontSize: 13)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30),
                      child: DefaultEditText(
                        keyboardType: TextInputType.emailAddress,
                        textController: emailController,
                        hintText: AppString.email.tr,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30),
                      child: ButtonTheme(
                        child: TextButton(
                          onPressed: () async {
                            var result =
                                await service.verifyEmail(emailController.text);

                            if (result["status"] == "success") {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OTPScreen(
                                      email: emailController.text,
                                      otp: result["otp"],
                                      forgotOTP: true,
                                    ),
                                  ));
                            } else {
                              snackBar(result["error"]);
                            }
                          },
                          child: Center(
                              child: Text(
                            AppString.verify_Email.tr.toUpperCase(),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          )),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: CustomColor.myCustomYellowDark,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              child: Loader(),
              visible: isLoading,
            )
          ],
        ));
  }

  snackBar(String? message) {
    return Fluttertoast.showToast(
        msg: message!.tr,
        backgroundColor: Colors.black,
        textColor: Colors.white);
  }
}
