import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/apiService/AuthServices.dart';
import 'package:titosapp/constants/constants.dart';
import 'package:titosapp/screens/ResetPassword.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/widgets/Header.dart';
import 'package:titosapp/widgets/Loader.dart';
import 'package:titosapp/widgets/OtpTimer.dart';
import 'package:titosapp/widgets/otp.dart';

import 'OTPVerified.dart';

// ignore: must_be_immutable
class OTPScreen extends StatefulWidget {
  String? email;
  int? otp;
  bool forgotOTP;

  OTPScreen({this.email = "", this.otp, this.forgotOTP = false});

  @override
  OTPScreenState createState() => OTPScreenState();
}

class OTPScreenState extends State<OTPScreen> with TickerProviderStateMixin {
  TextEditingController textEditingController = TextEditingController();

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  late Animation<double> animation;
  late AnimationController expandController;
  TextEditingController otpController = TextEditingController(text: "");

  late Timer timer;
  late int totalTimeInSeconds;
  late bool _hideResendButton;
  int time = 180;
  AuthService service = new AuthService();
  bool isLoading = false;

  @override
  void initState() {
    totalTimeInSeconds = time;
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: time))
          ..addStatusListener((status) {
            if (status == AnimationStatus.dismissed) {
              setState(() {
                _hideResendButton = !_hideResendButton;
              });
            }
          });
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
    _startCountdown();
    prepareAnimations();
  }

  Future<Null> _startCountdown() async {
    setState(() {
      _hideResendButton = true;
      totalTimeInSeconds = time;
    });
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
  }

  void prepareAnimations() {
    expandController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // snackBar Widget
  snackBar(String? message) {
    return Fluttertoast.showToast(
        msg: message!.tr,
        backgroundColor: Colors.black,
        textColor: Colors.white);
  }

  get _getTimerText {
    return Container(
      height: 32,
      child: new Offstage(
        offstage: !_hideResendButton,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Icon(
              Icons.access_time,
              color: Colors.black,
            ),
            new SizedBox(
              width: 5.0,
            ),
            Text(AppString.remaining.tr,
                style: TextStyle(
                  color: Colors.black,
                )),
            OtpTimer(_controller, 15.0, Colors.black)
          ],
        ),
      ),
    );
  }

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
                        AppString.otp_Verification.tr,
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
                            text: AppString.enter_OTP.tr,
                            children: [
                              TextSpan(
                                  text: "${widget.email}",
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
                    Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 30),
                        child: PinCodeFields(
                          controller: otpController,
                          length: 4,
                          fieldBorderStyle: FieldBorderStyle.Square,
                          responsive: false,
                          fieldHeight: 40.0,
                          fieldWidth: 40.0,
                          borderWidth: 1.0,
                          activeBorderColor: Colors.black,
                          activeBackgroundColor: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          keyboardType: TextInputType.number,
                          autoHideKeyboard: false,
                          fieldBackgroundColor: Colors.white,
                          borderColor: Colors.black38,
                          textStyle: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                          onComplete: (output) {
                            // Your logic with pin code
                            print(output);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text(
                        hasError ? AppString.otp_Validation.tr : "",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _getTimerText,
                    Offstage(
                      offstage: _hideResendButton,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppString.did_not_Receive_OTP.tr,
                            style:
                                TextStyle(color: Colors.black54, fontSize: 15),
                          ),
                          TextButton(
                              onPressed: () async {
                                setState(() {
                                  //_hideResendButton=false;
                                  isLoading = true;
                                });
                                var result = await service
                                    .resendOTP(widget.email.toString());

                                widget.otp = result["otp"] ?? 0;
                                if (widget.otp != 0) {
                                  setState(() {
                                    time = 15;
                                    _startCountdown();
                                    isLoading = false;
                                  });
                                }
                              },
                              child: Text(
                                AppString.resend.tr,
                                style: TextStyle(
                                    color: Colors.black, //Color(0xFF91D3B3),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16),
                              ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 14,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30),
                      child: ButtonTheme(
                        child: TextButton(
                          onPressed: () async {
                            if (otpController.text.isNotEmpty) {
                              if (widget.otp == int.parse(otpController.text)) {
                                if (!widget.forgotOTP) {
                                  var result = await service
                                      .verifyOTP(widget.email.toString());

                                  if (result["status"] == "success") {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OTPVerified(email: widget.email),
                                        ));
                                  } else {
                                    snackBar(result["message"]);
                                  }
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ResetPasswordScreen(
                                                email: widget.email),
                                      ));
                                }
                              } else {
                                snackBar(AppString.otp_Validation);
                              }
                            } else {
                              snackBar(AppString.otp_Validation);
                            }
                          },
                          child: Center(
                              child: Text(
                            AppString.verify_and_proceed.tr.toUpperCase(),
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
}
