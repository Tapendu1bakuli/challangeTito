import 'dart:io' show Directory, Platform, exit;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
 import 'package:titosapp/Store/HiveStore.dart';
import 'package:titosapp/apiService/AuthServices.dart';
import 'package:titosapp/model/UserModel.dart';
import 'package:titosapp/screens/dashboard/HomeScreen.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/Assets.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';
import 'package:titosapp/util/localStorage.dart';
import 'package:titosapp/widgets/CustomElevatedButton.dart';
import 'package:titosapp/widgets/CustomTextField.dart';
import 'package:titosapp/widgets/Header.dart';
import 'package:titosapp/widgets/Loader.dart';

import '../Store/ShareStore.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late FocusNode emailFocus, passwordFocus;
  bool emailFocused = false, passFocused = false;
  AuthService service = new AuthService();
  bool isLoading = false;
  var localStorage = new LocalHiveStorage();
  DateTime? backbuttonpressedTime;
  bool isPasswordVisible = true;

  @override
  void initState() {
    emailFocus = FocusNode();
    passwordFocus = FocusNode();
    ShareStore().saveContext(object: context);
    emailFocus.addListener(() {
      setState(() {
        if (emailFocus.hasFocus)
          emailFocused = true;
        else
          emailFocused = false;
      });
    });
    passwordFocus.addListener(() {
      setState(() {
        if (passwordFocus.hasFocus)
          passFocused = true;
        else
          passFocused = false;
      });
    });
    super.initState();
  }

  Future<bool> onWillPop() async {
    DateTime currentTime = DateTime.now();

    //Statement 1 Or statement2
    bool backButton = backbuttonpressedTime == null ||
        currentTime.difference(backbuttonpressedTime!) > Duration(seconds: 3);

    if (backButton) {
      backbuttonpressedTime = currentTime;
      Fluttertoast.showToast(
          msg: AppString.exitApp.tr,
          backgroundColor: Colors.black,
          textColor: Colors.white);
      return false;
    }
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Stack(
                children: [
                  SafeArea(
                      child: ListView(
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.all(35),
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        child: Header(),
                      ),
                      // Container(
                      //   height: 20,
                      // ),
                      // Container(
                      //   alignment: Alignment.center,
                      //   padding: EdgeInsets.all(10),
                      //   child: Text(
                      //     'LOGIN',
                      //     style: TextStyle(
                      //         color: Colors.black,
                      //         fontFamily: "Calibri",
                      //         fontWeight: FontWeight.w300,
                      //         fontSize: 30),
                      //   ),
                      // ),
                      (MediaQuery.of(context).size.width > 375)
                          ? Container(height: 100)
                          : SizedBox(height: 50),
                      Text(AppString.email.tr,
                          style: TextStyles.textStyleLight),
                      SizedBox(height: 12),
                      CustomTextField(
                        keyboardType: TextInputType.emailAddress,
                        focusNode: emailFocus,
                        textController: emailController,
                        hintText: AppString.enterEmail.tr,
                        suffixIcon: Image.asset(
                          Assets.emailIcon,
                          width: 20,
                        ),
                        // suffixIcon: Icon(Icons.alternate_email,
                        //     color: emailFocused ? Colors.black : Colors.grey),
                      ),
                      SizedBox(height: 32),

                      Text(AppString.password.tr,
                          style: TextStyles.textStyleLight),
                      SizedBox(height: 12),
                      CustomTextField(
                        focusNode: passwordFocus,
                        textController: passwordController,
                        obscureText: isPasswordVisible,
                        hintText: AppString.enterPassword.tr,
                        suffixIcon: IconButton(
                          icon: isPasswordVisible
                              ? Image.asset(
                                  Assets.passwordIcon,
                                  width: 20,
                                )
                              : Image.asset(
                                  Assets.passwordVisible,
                                  width: 20,
                                ),
                          onPressed: () => setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          }),
                        ),

                        // suffixIcon: Icon(Icons.lock_outline,
                        //     color: passFocused ? Colors.black : Colors.grey),
                      ),
                      SizedBox(height: 32),

                      Align(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, '/ForgotPasswordScreen');
                            //forgot password screen
                          },
                          child: Text(AppString.forgot_Password.tr,
                              textAlign: TextAlign.left,
                              style: TextStyles.textStyleLight),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      SizedBox(height: 32),

                      CustomElevatedButton(
                          text: AppString.signIn.tr,
                          widthFactor: 1,
                          onTap: () {
                            setState(() {
                              isLoading = true;
                            });
                            if (emailController.text.isNotEmpty &&
                                passwordController.text.isNotEmpty) {
                              login();
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                              snackBar(AppString.all_Fields_Required);
                            }
                          }),
                      /*  Align(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isLoading = true;
                            });
                            if (emailController.text.isNotEmpty &&
                                passwordController.text.isNotEmpty) {
                              login();
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                              snackBar(AppString.all_Fields_Required);
                            }
                          },
                          child: Container(
                            color: Colors.black,
                            child: Text(
                              'LOGIN',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                  fontSize: 16),
                            ),
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          ),
                        ),
                        alignment: Alignment.center,
                      ), */
                    ],
                  )),
                  _buildRegister(),
                  Visibility(
                    child: Loader(
                      text: "",
                    ),
                    visible: isLoading,
                  )
                ],
              ),
            ),
          ),
        ),
        onWillPop: onWillPop);
  }

  Widget _buildRegister() {
    return Positioned(
      bottom: 32,
      right: 32,
      child: Container(
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.bottomRight,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed('/Register');
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Spacer(),
              Text(AppString.register.tr,
                  style: TextStyles.textStyleRegular.apply(fontSizeDelta: 1)),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_right_alt_rounded,
                color: CustomColor.myCustomBlack,
                size: 20,
              ),
            ],
          ),
        ),
        padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
      ),
    );
  }

  snackBar(String? message) {
    return Fluttertoast.showToast(
        msg: message!.tr,
        backgroundColor: Colors.black,
        textColor: Colors.white);
  }

  login() async {
    //  String token  = await localStorage.getValue("token");
    String deviceType = "1", DeviceId = "";
    if (Platform.isIOS) {
      deviceType = "2";
    }

    if (Platform.isAndroid) {
      deviceType = "1";
    }
    String token = (await FirebaseMessaging.instance.getToken())!;
    DeviceId = (await _getId())!;
    var prefs = await HiveStore.getInstance();
    String? devicetoken = await prefs.getString("notificationtoken");
    UserModel user = new UserModel(
        email: emailController.text, password: passwordController.text);
    try {
      UserModel result =
          await service.login(user, token.toString(), DeviceId, deviceType);

      setState(() {
        isLoading = false;
      });

      if (result.id != 0) {
        snackBar(result.msg);
        localStorage.loginUser(result);
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return HomeScreen(
            walletBalance: result.walletBalance!,
          );
        }));
        // Navigator.pushNamed(context, '/Onboard');
      } else {
        // showAlertDialog(context,"error:" + result.msg);
        snackBar(result.msg);
        print(result.msg);
      }
    } catch (ex) {
      //showAlertDialog(context,ex.toString());

      print("EX: $ex");
      setState(() {
        isLoading = false;
      });
      snackBar(AppString.something_is_Wrong);
    }
  }

  showAlertDialog(BuildContext context, String msg) {
    // set up the button
    Widget okButton = TextButton(
      child: Text(
        AppString.ok.tr,
        style: TextStyle(
            fontWeight: FontWeight.bold, color: CustomColor.myCustomYellow),
      ),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: CustomColor.lightblack,
      title: Text(
        msg.tr,
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }
}
