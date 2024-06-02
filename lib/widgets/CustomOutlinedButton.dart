import 'package:flutter/material.dart';
import 'package:titosapp/util/TextStyles.dart';

class CustomOutlinedButton extends StatelessWidget {
  final Function() onTap;
  final String text;
  final double widthFactor;

  const CustomOutlinedButton(
      {required this.text, required this.widthFactor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black, alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(15),
            side: BorderSide(width: 2),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyles.textStyleRegular,
        ),
      ),
    );
  }
}
