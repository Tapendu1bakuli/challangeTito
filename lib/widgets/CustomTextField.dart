import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController textController;

  //final Function onChanged;
  final String hintText;
  final bool obscureText;
  final bool autofocus;
  final TextInputType keyboardType;
  final bool readOnly;
  final FocusNode focusNode;
  final Color fillColor;
  Widget suffixIcon;

  CustomTextField(
      {this.obscureText = false,
      this.hintText = '',
      required this.textController,
      this.autofocus = false,
      this.keyboardType = TextInputType.text,
      this.readOnly = false,
      required this.suffixIcon,
      required this.focusNode,
      this.fillColor = CustomColor.colorGrey});

  Widget build(BuildContext _context) {
    return Container(
      child: TextFormField(
        focusNode: focusNode,
        cursorColor: Colors.black,
        keyboardType: keyboardType,
        obscureText: obscureText,
        controller: textController,
        decoration: InputDecoration(
          suffixIconConstraints: BoxConstraints(minHeight: 30, minWidth: 30),
          contentPadding: EdgeInsets.all(15),
          isDense: true,
          filled: true,
          fillColor: CustomColor.colorGrey,
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: suffixIcon,
          ),
          hintText: hintText.tr,
          hintStyle: TextStyles.textStyleRegular,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(5),
            // borderSide: BorderSide(color: CustomColor.myCustomBlack, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,

            borderRadius: BorderRadius.circular(5),
            // borderSide: BorderSide(color: CustomColor.myCustomBlack, width: 2),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,

            borderRadius: BorderRadius.all(Radius.circular(5)),
            // borderSide:
            //     BorderSide(color: CustomColor.myCustomBlack, width: 2)
          ),
        ),
      ),
    );
  }
}
