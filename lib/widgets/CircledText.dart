import 'package:flutter/material.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';

class CircledText extends StatelessWidget {
  final Color color;
  final String text;
  final Color textColor;
  final double fontSize;
  final BuildContext context;

  CircledText(
      {required this.context,
      this.color = Colors.white,
      this.text = '',
      this.textColor = Colors.black,
      this.fontSize = 14});

  @override
  Widget build(BuildContext _context) {
    return Container(
      alignment: Alignment.center,
      width: 105,
      height: 105,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyles.textStyleBold
                .apply(color: CustomColor.colorTextHint, fontSizeFactor: 1.35),
          ),
        ],
      ),
    );
  }
}
