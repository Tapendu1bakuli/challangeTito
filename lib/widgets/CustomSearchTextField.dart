import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';

class CustomSearchTextField extends StatelessWidget {
  final TextEditingController textController;
  final Function() onTap;
  final Function()? onWidgetPressed;
  final bool obscureText;
  final bool autofocus;
  final bool isLoading;
  final String hintText;
  final TextInputType keyboardType;
  final bool readOnly;
  final FocusNode focusNode;
  final Color fillColor;
  final IconData? icon;

  CustomSearchTextField(
      {this.obscureText = false,
      required this.textController,
      this.autofocus = false,
      this.keyboardType = TextInputType.text,
      this.readOnly = false,
      required this.focusNode,
      required this.onTap,
      this.onWidgetPressed,
      this.fillColor = CustomColor.colorGrey,
      required this.isLoading,
      this.hintText = "Search",
      this.icon});

  Widget build(BuildContext _context) {
    return Container(
      child: TextFormField(
        onTap: onWidgetPressed,
        readOnly: readOnly,
        focusNode: focusNode,
        cursorColor: Colors.black,
        keyboardType: keyboardType,
        obscureText: obscureText,
        controller: textController,
        decoration: InputDecoration(
          suffixIconConstraints: BoxConstraints(minHeight: 30, minWidth: 30),
          contentPadding: EdgeInsets.all(10),
          isDense: true,
          filled: true,
          fillColor: CustomColor.white,
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              child: Icon(
                icon ?? Icons.search_outlined,
                size: 24,
                color: Colors.black,
              ),
              onTap: isLoading ? null : onTap,
            ),
          ),
          hintText: hintText.tr,
          hintStyle: TextStyles.textStyleRegular,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: CustomColor.colorBorderSearch, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: CustomColor.colorBorderSearch, width: 2),
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide:
                  BorderSide(color: CustomColor.colorBorderSearch, width: 2)),
        ),
      ),
    );
  }
}
