import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';

class VotingOverlayTOS extends StatefulWidget {
  final String walletBalance;

  VotingOverlayTOS({required this.walletBalance});

  @override
  State<StatefulWidget> createState() => VotingOverlayTOSState();
}

class VotingOverlayTOSState extends State<VotingOverlayTOS>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Animation<double>? scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    scaleAnimation =
        CurvedAnimation(parent: controller!, curve: Curves.elasticInOut);

    controller!.addListener(() {
      setState(() {});
    });

    controller!.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: CustomColor.colorDiaBlue,
        child: ScaleTransition(
          scale: scaleAnimation!,
          child: Container(
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.all(15.0),
              height: MediaQuery.of(context).size.width / 2.5,
              width: 300,
              decoration: ShapeDecoration(
                  color: CustomColor.colorDiaBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              child: Stack(
                children: [
                  Positioned(
                      top: 0,
                      right: 0,
                      child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                          ))),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            AppString.bonusTOS.tr,
                            style: TextStyles.textStyleBold
                                .apply(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
