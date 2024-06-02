import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/util/CustomColor.dart';

class DefaultEditText extends StatelessWidget {
  final TextEditingController textController;

  //final Function onChanged;
  final String hintText;
  final bool obscureText;
  final bool autofocus;
  final TextInputType keyboardType;
  final bool readOnly;

  DefaultEditText(
      {this.obscureText = false,
      this.hintText = '',
      required this.textController,
      this.autofocus = false,
      this.keyboardType = TextInputType.text,
      this.readOnly = false});

  Widget build(BuildContext _context) {
    return Container(
      child: TextFormField(
        inputFormatters: [
          // is able to enter lowercase letters
          // FilteringTextInputFormatter.allow(RegExp("[a-z]")),
          //FilteringTextInputFormatter.deny(' ')
        ],
        readOnly: readOnly,
        keyboardType: keyboardType,
        obscureText: obscureText,
        controller: textController,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: hintText.tr,
          fillColor: Colors.white,
          filled: true,
          hintStyle: TextStyle(
              letterSpacing: 0,
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.normal),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: CustomColor.myCustomBlack, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: CustomColor.myCustomBlack, width: 2),
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                color: CustomColor.myCustomBlack,
                width: 2,
              )),
        ),
      ),
    );
  }
}
