import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/screens/voting/VotingList.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';

class VotingOverlay extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => VotingOverlayState();
}

class VotingOverlayState extends State<VotingOverlay>
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
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation!,
          child: Container(
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.all(15.0),
              height: 280.0,
              width: 300,
              decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              child: Stack(
                children: [
                  Positioned(
                      top: 0,
                      right: 0,
                      child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close))),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 30.0, left: 20.0, right: 20.0, bottom: 24),
                          child: Text(
                            AppString.selectOption.tr,
                            style: TextStyles.textStyleBold
                                .apply(color: Colors.black),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)), backgroundColor: Colors.black,
                              minimumSize: Size(200, 50)),
                          child: Text(
                            AppString.dance.tr,
                            textAlign: TextAlign.center,
                            style: TextStyles.textStyleSemiBold,
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        VotingList(option: 2)));
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)), backgroundColor: CustomColor.colorYellow,
                              minimumSize: Size(200, 50)),
                          child: Text(
                            AppString.sing.tr,
                            textAlign: TextAlign.center,
                            style: TextStyles.textStyleSemiBold
                                .apply(color: Colors.black),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        VotingList(option: 1)));
                          },
                        )
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
