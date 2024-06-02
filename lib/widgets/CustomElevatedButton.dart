import 'package:flutter/material.dart';
import 'package:titosapp/util/TextStyles.dart';

class CustomElevatedButton extends StatelessWidget {
  final Function() onTap;
  final String text;
  final double widthFactor;

  const CustomElevatedButton(
      {required this.text, required this.widthFactor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(15), backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyles.textStyleSemiBold,
        ),
      ),
    );
  }
}
