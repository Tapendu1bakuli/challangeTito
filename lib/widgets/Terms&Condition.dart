import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAndCondition extends StatelessWidget {
  final Color color;
  final String text;
  final Color textColor;

  TermsAndCondition(
      {this.color = Colors.white,
      this.text = '',
      this.textColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
          text: AppString.registerOur.tr,
          style: TextStyle(
            fontFamily: "Calibre",
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          children: <TextSpan>[
            TextSpan(
              text: AppString.termsAndCond.tr,
              style: TextStyle(
                fontFamily: "Calibre",
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              recognizer: new TapGestureRecognizer()
                ..onTap = () {
                  launch('https://mytitos.com/terms');
                },
            ),
            TextSpan(
              text: AppString.and.tr,
              style: TextStyle(
                fontFamily: "Calibre",
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: AppString.privacy.tr,
              style: TextStyle(
                fontFamily: "Calibre",
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              recognizer: new TapGestureRecognizer()
                ..onTap = () {
                  launch('https://mytitos.com/privacy_policy');
                },
            ),
          ]),
    );
  }
}
