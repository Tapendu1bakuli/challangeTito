import 'dart:io';

import 'package:titosapp/Service/CoreService.dart';
import 'package:titosapp/Service/GlobalKeys.dart';
import 'package:titosapp/model/PaymentAccountModel.dart';
import 'package:titosapp/model/UserModel.dart';
import 'package:titosapp/model/payment/PaymentAccountListModel.dart';
import 'package:titosapp/util/localStorage.dart';

import '../model/payment/CardPayment.dart';

class PaymentService {
  var localStorage = new LocalHiveStorage();

  getAccountTypes() async {
    PaymentAccountModel? result;
    String accessToken = await localStorage.getValue("access_token");
    final response = await CoreService().apiService(
      method: METHOD.GET,
      endpoint: GlobalKeys.PAYMENT_ACCOUNT_TYPES,
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );
    result = PaymentAccountModel.fromJson(response);

    return result;
  }

  paymentAccountSave(int paymentAccountId, String paymentAccountAddress,
      {String? mobileMoneyId}) async {
    UserModel result = new UserModel();
    String accesstoken = await localStorage.getValue("access_token");
    String id = await localStorage.getValue("id");
    Map data = {
      "paymentAccountId": paymentAccountId.toString(),
      "paymentAccountAddress": paymentAccountAddress,
      "mobile_money_id": mobileMoneyId
    };
    String accessToken = await localStorage.getValue("access_token");
    final response = await CoreService().apiService(
      method: METHOD.POST,
      endpoint: GlobalKeys.PAYMENT_ACCOUNT_SAVE,
      body: data,
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );
    var status = response["status"] ?? "";
    if (status == "failure")
      result.msg = response["error"] ?? "";
    else
      result.msg = response["message"] ?? "";

    result.paymentAccountId = int.parse(response["payment_id"] ?? "0");

    return result;
  }

  getAccount(String password) async {
    PaymentAccountListModel? result;
    Map data = {
      "password": password,
    };
    String accessToken = await localStorage.getValue("access_token");
    final response = await CoreService().apiService(
        method: METHOD.POST,
        endpoint: GlobalKeys.PAYMENT_ACCOUNT_LIST,
        header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
        body: data);
    result = PaymentAccountListModel.fromJson(response);

    return result;
  }

  paymentByCard(
      {required int tosToken,
      required int cardNo,
      required int cardExpiryMonth,
      required int cardExpiryYear,
      required int cardCvv}) async {
    var result;
    Map data = {
      "tos_token": tosToken,
      "card_no": cardNo,
      "expiry_month": cardExpiryMonth,
      "expiry_year": cardExpiryYear,
      "security_code": cardCvv,
    };
    String accessToken = await localStorage.getValue("access_token");
    final response = await CoreService().apiService(
      method: METHOD.POST,
      endpoint: GlobalKeys.PAYMENT_CARD,
      body: data,
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    result = CardPaymentModel.fromJson(response);

    return result;
  }
}
