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

class ResetPasswordScreen extends StatefulWidget {
  String? email;

  ResetPasswordScreen({this.email = ""});

  @override
  ResetPasswordScreenState createState() => new ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController passwordController = TextEditingController();
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
                        AppString.change_Password.tr,
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
                                  text: AppString.enter_new_Password.tr,
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
                        textController: passwordController,
                        hintText: AppString.password.tr,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30),
                      child: ButtonTheme(
                        child: TextButton(
                          onPressed: () async {
                            var result = await service.resetPassword(
                                widget.email.toString(),
                                passwordController.text);

                            if (result["status"] == "success") {
                              snackBar(AppString.passwordUpdated);
                              goAuth();
                            } else {
                              snackBar(result["error"]);
                            }
                          },
                          child: Center(
                              child: Text(
                            AppString.update.tr.toUpperCase(),
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

  goAuth() {
    Navigator.pushNamedAndRemoveUntil(
        context, '/Login', (Route<dynamic> route) => false);
  }

  snackBar(String? message) {
    return Fluttertoast.showToast(
        msg: message!.tr,
        backgroundColor: Colors.black,
        textColor: Colors.white);
  }
}
