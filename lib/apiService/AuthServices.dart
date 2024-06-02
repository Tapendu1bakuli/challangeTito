import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:titosapp/Service/CoreService.dart';
import 'package:titosapp/Service/GlobalKeys.dart';
import 'package:titosapp/model/UserModel.dart';
import 'package:titosapp/util/localStorage.dart';

import '../Store/HiveStore.dart';
import '../screens/LanguageSelectionScreen.dart';

class AuthService {
  var localStorage = new LocalHiveStorage();

  login(
      UserModel user, String token, String deviceId, String deviceType) async {
    UserModel? result;
    Map data = {
      "email": user.email,
      "password": user.password,
      "fcmToken": token,
      "deviceId": deviceId,
      "deviceType": deviceType
    };
    final response = await CoreService().apiService(
      method: METHOD.POST,
      endpoint: GlobalKeys.LOGIN,
      body: data,
    );
    if (response["status"] == "success") {
      result = UserModel.fromJson(response["userData"]);
      result.msg = response["message"];
    } else {
      result = new UserModel(id: 0, msg: response["error"] ?? "");
    }

    return result;
  }

  registerUser(UserModel user) async {
    var result;
    print("LANG: ${user.lang}");
    Map data = {
      "firstName": user.firstName,
      "lastName": user.lastName,
      "city": user.city,
      "country": user.country,
      "email": user.email,
      "password": user.password,
      "lenguage": user.lang,
      "countryCode": user.countryCode,
      "local_zone": user.localZone
    };
    final response = await CoreService().apiService(
      method: METHOD.POST,
      endpoint: GlobalKeys.SIGN_UP,
      body: data,
    );
    if (response["status"] == "success") {
      result = UserModel.fromSignUpJson(response);
    } else {
      result =
          new UserModel(status: response["status"], msg: response["error"]);
    }
    return result;
  }

  resendOTP(String email) async {
    final response = await CoreService().apiService(
        method: METHOD.GET,
        endpoint: GlobalKeys.RESEND_OTP,
        params: {"email": email});

    return response;
  }

  verifyOTP(String email) async {
    final response = await CoreService().apiService(
        method: METHOD.GET,
        endpoint: GlobalKeys.VERIFY_OTP,
        params: {"email": email});

    return response;
  }

  verifyEmail(String email) async {
    Map data = {"email": email};

    final response = await CoreService().apiService(
      method: METHOD.POST,
      endpoint: GlobalKeys.FORGOT_PASSWORD,
      body: data,
    );

    return response;
  }

  resetPassword(String email, String password) async {
    Map data = {"email": email, "newPassword": password};
    final response = await CoreService().apiService(
      method: METHOD.POST,
      endpoint: GlobalKeys.RESET_PASSWORD,
      body: data,
    );

    return response;
  }

  changePassword(
      String password, String newPassword, String confirmPassword) async {
    String accesstoken = await localStorage.getValue("access_token");
    Map data = {
      "current_password": password,
      "new_password": newPassword,
      "new_password_confirmation": confirmPassword
    };
    final response = await CoreService().apiService(
      method: METHOD.POST,
      endpoint: GlobalKeys.CHANGE_PASSWORD,
      header: {HttpHeaders.authorizationHeader: "Bearer $accesstoken"},
      body: data,
    );

    return response;
  }

  editProfile(String fname, String lname, String city, String country,
      String email) async {
    String accesstoken = await localStorage.getValue("access_token");
    Map data = {
      "firstName": fname,
      "lastName": lname,
      "city": city,
      "country": country,
      "email": email
    };
    final response = await CoreService().apiService(
      method: METHOD.POST,
      endpoint: GlobalKeys.UPDATE_PROFILE,
      header: {HttpHeaders.authorizationHeader: "Bearer $accesstoken"},
      body: data,
    );

    return response;
  }

  logOut() async {
    String accesstoken = await localStorage.getValue("access_token");
    var prefs = await HiveStore.getInstance();
    String? devicetoken = await prefs.getString("notificationtoken");

    Map data = {
      "fcm_token": devicetoken.toString(),
    };
    final response = await CoreService().apiService(
      method: METHOD.POST,
      endpoint: GlobalKeys.LOG_OUT,
      header: {HttpHeaders.authorizationHeader: "Bearer $accesstoken"},
      body: data,
    );
    // LocalizationService().changeLocale("English");
    await localStorage.logout();

    return response;
  }

  deleteAccountFromServer() async {
    String accesstoken = await localStorage.getValue("access_token");
    var prefs = await HiveStore.getInstance();
    final response = await CoreService().apiService(
      method: METHOD.GET,
      endpoint: GlobalKeys.DELETE_USER,
      header: {HttpHeaders.authorizationHeader: "Bearer $accesstoken"},
    );
    if(response["status"]){
      await localStorage.logout();
      Get.offAll(() => LanguageSelectionScreen());
    }else{
      return Fluttertoast.showToast(
          msg: response["msg"]!.tr,
          backgroundColor: Colors.black,
          textColor: Colors.white);
    }
    return response;
  }
}
