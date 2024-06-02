import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../Store/ShareStore.dart';
import '../apiService/AuthServices.dart';
import '../screens/LanguageSelectionScreen.dart';
import '../util/AppString.dart';
import 'AppException.dart';
import 'GlobalKeys.dart';

class CoreService {
  BuildContext? context;

  static late bool isShowing = true;

  //Singleton Class
  static final CoreService _default = new CoreService._internal();

  factory CoreService() {
    return _default;
  }

  CoreService._internal();

  static getInstance() {
    return _default;
  }

  Future apiService(
      {GlobalKey? key,
      header,
      body,
      bool multiPart = false,
      params,
      METHOD method = METHOD.POST,
      SSL ssl = SSL.HTTPS,
      baseURL = GlobalKeys.BASE_URL,
      commonPoint = GlobalKeys.APIV1,
      endpoint,
      filePath,
      String fileKey = 'document_name',
      attachmentList,
      nextFileKey}) async {
    context = ShareStore().getContext();
    if (await networkCheck()) {
      print("isShowing : $isShowing");
      showDialog(
        context: context!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          // return object of type Dialog
          if (isShowing) {
            isShowing = false;
            return AlertDialog(
              title: new Text("No Network Found".tr),
              content: new Text("Please check your internet connection".tr),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new TextButton(
                  child: Text(AppString.close.tr),
                  onPressed: () {
                    isShowing = true;
                    print("isShowing : $isShowing");
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          } else {
            isShowing = false;
            Navigator.pop(context);
            return AlertDialog(
              title: new Text("No Network Found".tr),
              content: new Text("Please check your internet connection".tr),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new TextButton(
                  child: Text(AppString.close.tr),
                  onPressed: () {
                    isShowing = true;
                    print("isShowing : $isShowing");
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
        },
      );
    } else {
      var param;
      if (multiPart) {
        param = {
          'uploadType': params.toString(),
        };
      } else {
        param = params;
      }
      var endPoint = commonPoint + endpoint;
      var uri;
      if (ssl == SSL.HTTP) {
        uri =
            Uri.http(Uri.encodeFull(baseURL), Uri.encodeFull(endPoint), param);
      } else {
        uri =
            Uri.https(Uri.encodeFull(baseURL), Uri.encodeFull(endPoint), param);
      }

      Map<String, String> requestHeaders = method == METHOD.MULTIPART
          ? {
              'Content-type': 'multipart/form-data',
              HttpHeaders.acceptHeader: 'application/json',
            }
          : {
              'Content-type': 'application/json',
              HttpHeaders.acceptHeader: 'application/json',
            };
      if (header != null) {
        requestHeaders.addAll(header);
      }
      if (body != null && method != METHOD.MULTIPART) {
        body = json.encode(body);
      }
      debugPrint("Header :  $requestHeaders");
      debugPrint("Body :  $body");
      debugPrint("Params :  $params");
      debugPrint("URL :  $uri");
      debugPrint("Method :  $method");

      switch (method) {
        case METHOD.GET:
          {
            var responseJson;
            try {
              final response = await http.get(uri, headers: requestHeaders);
              responseJson = _returnResponse(response);
            } on SocketException {
            } catch (error) {
              Get.back();
              print(error);
            }
            return responseJson;
          }
        case METHOD.PUT:
          {
            var responseJson;
            try {
              final response =
                  await http.put(uri, headers: requestHeaders, body: body);
              responseJson = _returnResponse(response);
            } on SocketException {
            } catch (error) {
              Get.back();
              print(error);
            }
            return responseJson;
          }
        case METHOD.DELETE:
          {
            var responseJson;
            try {
              final response = await http.delete(uri, headers: requestHeaders);
              responseJson = _returnResponse(response);
            } on SocketException {
            } catch (error) {
              Get.back();
              print(error);
            }
            return responseJson;
          }
        case METHOD.PATCH:
          {
            var responseJson;
            try {
              final response =
                  await http.patch(uri, headers: requestHeaders, body: body);
              responseJson = _returnResponse(response);
            } on SocketException {
            } catch (error) {
              Get.back();
              print(error);
            }
            return responseJson;
          }
        case METHOD.POST:
          {
            var responseJson;
            var response;
            try {
              debugPrint("body: $body");
              response =
                  await http.post(uri, headers: requestHeaders, body: body);
              responseJson = _returnResponse(response);
            } on SocketException {
            } on Exception {
              debugPrint(
                  "Exception block : Try again or revisit the screen. ${response.body}");
              Get.back();
              Fluttertoast.showToast(
                  msg: AppString.something_is_Wrong.tr,
                  backgroundColor: Colors.black,
                  textColor: Colors.white);
              throw UnknownException("Try again or revisit the screen.");
            } catch (error) {
              Get.back();
              Fluttertoast.showToast(
                  msg: AppString.something_is_Wrong.tr,
                  backgroundColor: Colors.black,
                  textColor: Colors.white);
              debugPrint("Catch block:  $error");
            }
            return responseJson;
          }
        case METHOD.MULTIPART:
          {
            var responseJson;

            try {
              var request = http.MultipartRequest(
                'POST',
                uri,
              );
              if (header != null) {
                request.headers.addAll(header);
              }
              if (body != null) {
                request.fields.addAll(body);
              }
              if (filePath is List<File>) {
                List<http.MultipartFile> data = <http.MultipartFile>[];
                for (int i = 0; i < filePath.length; i++) {
                  final mimeTypeData = lookupMimeType(filePath[i].path,
                          headerBytes: [0xFF, 0xD8])!
                      .split('/');
                  data.add(await http.MultipartFile.fromPath(
                      '$fileKey[$i]', filePath[i].path,
                      contentType:
                          MediaType(mimeTypeData[0], mimeTypeData[1])));
                }
                request.files.addAll(data);
              } else {
                final mimeTypeData =
                    lookupMimeType(filePath, headerBytes: [0xFF, 0xD8])!
                        .split('/');
                request.files.add(await http.MultipartFile.fromPath(
                    fileKey, filePath,
                    contentType: MediaType(mimeTypeData[0], mimeTypeData[1])));
                debugPrint("Request : $request");
              }
              if (attachmentList != null && nextFileKey != null) {
                if (attachmentList is List<File>) {
                  if (attachmentList.length > 0) {
                    List<http.MultipartFile> data = <http.MultipartFile>[];
                    for (int i = 0; i < filePath.length; i++) {
                      final mimeTypeData = lookupMimeType(filePath[i].path,
                              headerBytes: [0xFF, 0xD8])!
                          .split('/');
                      data.add(await http.MultipartFile.fromPath(
                          '$nextFileKey[$i]', attachmentList[i].path,
                          contentType:
                              MediaType(mimeTypeData[0], mimeTypeData[1])));
                    }
                    request.files.addAll(data);
                  }
                } else {
                  final mimeTypeData =
                      lookupMimeType(filePath, headerBytes: [0xFF, 0xD8])!
                          .split('/');
                  request.files.add(await http.MultipartFile.fromPath(
                      nextFileKey, attachmentList,
                      contentType:
                          MediaType(mimeTypeData[0], mimeTypeData[1])));
                  debugPrint("Request : $request");
                }
              }
              final http.StreamedResponse response = await request.send();
              debugPrint("API_Status: ${response.reasonPhrase}");
              responseJson = await http.Response.fromStream(response);
              responseJson = _returnResponse(responseJson);
            } on SocketException {
            } catch (error) {
              Get.back();
              debugPrint(error.toString());
            }
            return responseJson;
          }
        default:
          {
            var responseJson;
            try {
              final response =
                  await http.post(uri, headers: requestHeaders, body: body);
              responseJson = _returnResponse(response);
            } on SocketException {
            } catch (error) {
              Get.back();
              print(error);
            }
            return responseJson;
          }
      }
    }
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 422:
        {
          String message = "";
          var responseJson = json.decode(
              Utf8Decoder().convert(response.body.toString().codeUnits));
          if (responseJson is List) {
          } else if (responseJson["error"] == "Your account is deactivated.") {
            message = "Your account is deactivated.";
            return showDialog(
              context: context!,
              barrierDismissible: false,
              builder: (BuildContext context) {
                // return object of type Dialog
                if (isShowing) {
                  isShowing = false;
                  return AlertDialog(
                    title: new Text(AppString.alert.tr),
                    content: new Text(message.tr),
                    actions: <Widget>[
                      // usually buttons at the bottom of the dialog
                      new TextButton(
                        child: Text(AppString.ok.tr),
                        onPressed: () {
                          isShowing = true;
                          AuthService().logOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    LanguageSelectionScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  );
                } else {
                  isShowing = false;
                  Navigator.pop(context);
                  return AlertDialog(
                    title: new Text(AppString.alert.tr),
                    content: new Text(message.tr),
                    actions: <Widget>[
                      // usually buttons at the bottom of the dialog
                      new TextButton(
                        child: Text(AppString.ok.tr),
                        onPressed: () {
                          isShowing = true;
                          AuthService().logOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    LanguageSelectionScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            );
          }
          debugPrint("Result : $responseJson");
          return responseJson;
        }

      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
        return showDialog(
          context: context!,
          builder: (BuildContext context) {
            var responseJson = json.decode(
                Utf8Decoder().convert(response.body.toString().codeUnits));
            String message = responseJson["message"] == "Unauthenticated."
                ? "Unauthenticated or Session Expired, Please Login"
                : responseJson["message"];
            // return object of type Dialog
            if (isShowing) {
              isShowing = false;
              return AlertDialog(
                title: new Text(AppString.alert.tr),
                content: new Text(message.tr),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  new TextButton(
                    child: Text(AppString.ok.tr),
                    onPressed: () {
                      isShowing = true;
                      AuthService().logOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                LanguageSelectionScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              );
            } else {
              isShowing = false;
              Navigator.pop(context);
              return AlertDialog(
                title: new Text(AppString.alert.tr),
                content: new Text(message.tr),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  new TextButton(
                    child: Text(AppString.ok.tr),
                    onPressed: () {
                      isShowing = true;
                      AuthService().logOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                LanguageSelectionScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              );
            }
          },
        );
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }

  Future<bool> networkCheck() async {
    try {
      final result = await InternetAddress.lookup('${GlobalKeys.GOOGLE}');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return false;
      } else {
        return true;
      }
    } on SocketException catch (_) {
      return true;
    }
  }
}

enum METHOD {
  GET,
  PUT,
  POST,
  DELETE,
  PATCH,
  MULTIPART,
}

enum SSL {
  HTTP,
  HTTPS,
}
