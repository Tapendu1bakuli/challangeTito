import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../util/CustomColor.dart';
import '../util/TextStyles.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController textController;

  //final Function onChanged;
  final String hintText;
  final bool obscureText;
  final bool autofocus;
  final TextInputType keyboardType;
  final bool readOnly;
  final Color fillColor;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final Widget? icon;

  CustomTextFormField(
      {this.obscureText = false,
      this.hintText = '',
      required this.textController,
      this.autofocus = false,
      this.keyboardType = TextInputType.text,
      this.readOnly = false,
      this.fillColor = CustomColor.colorGrey,
      this.inputFormatters,
      this.onSaved,
      this.validator,
      this.icon});

  Widget build(BuildContext _context) {
    return Container(
      child: TextFormField(
        cursorColor: Colors.black,
        keyboardType: keyboardType,
        obscureText: obscureText,
        controller: textController,
        inputFormatters: inputFormatters,
        onSaved: onSaved,
        validator: validator,
        decoration: InputDecoration(
          suffixIconConstraints: BoxConstraints(minHeight: 30, minWidth: 30),
          contentPadding: EdgeInsets.all(15),
          isDense: true,
          filled: true,
          fillColor: CustomColor.colorGrey,
          hintText: hintText.tr,
          hintStyle: TextStyles.textStyleRegular,
          icon: icon,
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
