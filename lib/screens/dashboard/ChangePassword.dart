import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/apiService/AuthServices.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/widgets/DefaultEditText.dart';
import 'package:titosapp/widgets/Loader.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  ChangePasswordScreenState createState() => new ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  AuthService service = new AuthService();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CustomColor.customGrey,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            AppString.change_Password.tr,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
          leading: IconButton(
            icon: new Icon(
              Icons.arrow_back_ios,
              color: CustomColor.myCustomYellow,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          children: [
            Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30),
                      child: DefaultEditText(
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        textController: currentPasswordController,
                        hintText: AppString.currentPassword.tr,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30),
                      child: DefaultEditText(
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        textController: newPasswordController,
                        hintText: AppString.enter_new_Password.tr,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30),
                      child: DefaultEditText(
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        textController: confirmPasswordController,
                        hintText: AppString.confirm_Password.tr,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30),
                      child: ButtonTheme(
                        child: TextButton(
                          onPressed: () async {
                            var result = await service.changePassword(
                                currentPasswordController.text,
                                newPasswordController.text,
                                confirmPasswordController.text);

                            if (result["status"] == "success") {
                              snackBar(AppString.passwordUpdated);
                            } else {
                              print(result["error"]);
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
                Visibility(
                  child: Loader(),
                  visible: isLoading,
                )
              ],
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
