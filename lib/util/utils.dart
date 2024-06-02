import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

dismissKeyboard(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);

  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
}

snackBar(String? message) {
  return Fluttertoast.showToast(
      msg: message!, backgroundColor: Colors.black, textColor: Colors.white);
}
