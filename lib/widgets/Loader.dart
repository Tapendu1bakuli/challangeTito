import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/util/CustomColor.dart';

class Loader extends StatelessWidget {
  final String text;
  final bool isTransparent;

  Loader({this.text = "Loading", this.isTransparent = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: isTransparent
          ? Colors.black.withOpacity(0.3)
          : CustomColor.myCustomBlack,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              height: 30,
              width: 30,
              child: SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  backgroundColor: CustomColor.myCustomYellowDark,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF707070),
                  ),
                ),
              )),
          SizedBox(
            height: 25,
          ),
          Container(
            child: Text(
              text.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 15.0),
            ),
          )
        ],
      ),
    );
  }
}
