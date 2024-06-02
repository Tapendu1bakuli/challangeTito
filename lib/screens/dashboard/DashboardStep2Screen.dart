import 'dart:io' show Platform, exit;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/Store/HiveStore.dart';
import 'package:titosapp/screens/dashboard/ChooseChallange.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/Assets.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';

import '../../Store/ShareStore.dart';

class DashboardStep2Screen extends StatefulWidget {
  @override
  State<DashboardStep2Screen> createState() => _DashboardStep2ScreenState();
}

class _DashboardStep2ScreenState extends State<DashboardStep2Screen> {
  DateTime? backbuttonpressedTime;

  ScrollController _scrollController = new ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  String? language = "";

  @override
  void initState() {
    _getPref();
    ShareStore().saveContext(object: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          bottomNavigationBar: _buildBottomWidget(context),
          backgroundColor: CustomColor.customGrey,
          body: Stack(children: [
            SafeArea(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    alignment: Alignment.center,
                    image: AssetImage(language == "English"
                        ? Assets.flow
                        : language == "FRANÇAIS"
                            ? Assets.flowSpanish
                            : Assets.flowKorean),
                  ),
                ),
              ),
            ),
            /* Positioned(
          child: SafeArea(
            child: GestureDetector(
              child: Container(
                child: Text(
                  "NEXT",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(0, 0, 10, 10),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return HomeScreen();
                }));
              },
            ),
          ),
          bottom: 0.5,
            ) */
          ]),
        ),
        onWillPop: onWillPop);
  }

  Widget _buildBottomWidget(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 56,
        color: Colors.white,
        child: GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) {
              return ChooseChallenge();
            }), (Route<dynamic> route) => false);
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppString.next.tr,
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
      ),
    );
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

  _getPref() {
    setState(() {
      language = HiveStore().get(Keys.language);
    });
  }
}
