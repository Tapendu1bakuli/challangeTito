import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_quill/flutter_inappwebview_quill.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/Store/ShareStore.dart';
import 'package:titosapp/apiService/MediaServices.dart';
import 'package:titosapp/model/payment/PaymentAccountListModel.dart';
import 'package:titosapp/screens/dashboard/HomeScreen.dart';
import 'package:titosapp/screens/transaction/TransactionSuccessful.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/Assets.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';
import 'package:titosapp/widgets/CustomTextField.dart';
import 'package:titosapp/widgets/Loader.dart';

import '../../Service/CoreService.dart';
import '../../Service/GlobalKeys.dart';
import '../../util/localStorage.dart';
import '../dashboard/MyTickets.dart';
import '../wallet/Wallet.dart';
import 'PaymentModes.dart';

class ValidateTransaction extends StatefulWidget {
  final tosToken;
  final String userId;
  final String page;
  final Map<String, dynamic> model;

  const ValidateTransaction(
      {Key? key,
      this.tosToken,
      this.userId = "",
      this.page = "",
      this.model = const <String, dynamic>{}})
      : super(key: key);

  @override
  _ValidateTransactionState createState() => _ValidateTransactionState();
}

class _ValidateTransactionState extends State<ValidateTransaction> {
  bool isPasswordVisible = true;
  bool isLoading = false;
  TextEditingController passwordTextController = TextEditingController();
  MediaService service = MediaService();
  late Map<String, dynamic> model = <String, dynamic>{};

  var focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
    model = widget.model;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.colorBgTransaction,
      appBar: _appBar(context),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 32),
              Image.asset(Assets.validateTransaction, width: 80),
              SizedBox(height: 20),
              Expanded(
                  child: Container(
                padding: EdgeInsets.all(28),
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        AppString.validateTransaction.tr,
                        style: TextStyles.textStyleRegular,
                      ),
                      _buildPassword(),
                      SizedBox(height: 32),
                      _buildBuyTokenButton()
                    ],
                  ),
                ),
              ))
            ],
          ),
          Visibility(
            child: Loader(),
            visible: isLoading,
          )
        ],
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      centerTitle: true,
      title: Text(
        AppString.transaction.tr.toUpperCase(),
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      automaticallyImplyLeading: false,
      actions: [
        InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Icon(Icons.close),
          ),
        )
      ],
    );
  }

  Widget _buildPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32),
        Text(AppString.enterPass.tr, style: TextStyles.textStyleLight),
        SizedBox(height: 12),
        CustomTextField(
          textController: passwordTextController,
          obscureText: isPasswordVisible,
          hintText: AppString.enterPassword.tr,
          suffixIcon: IconButton(
            icon: isPasswordVisible
                ? Image.asset(
                    Assets.passwordIcon,
                    width: 20,
                  )
                : Image.asset(
                    Assets.passwordVisible,
                    width: 20,
                  ),
            onPressed: () => setState(() {
              isPasswordVisible = !isPasswordVisible;
            }),
          ),
          focusNode: focusNode,

          // suffixIcon: Icon(Icons.lock_outline,
          //     color: passFocused ? Colors.black : Colors.grey),
        ),
      ],
    );
  }

  _buildBuyTokenButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            minimumSize: Size(double.maxFinite, 50), backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        onPressed: () {
          if (passwordTextController.text.isEmpty) {
          } else {
            if (widget.page.isNotEmpty) {
              switch (widget.page) {
                case "BuyTicket":
                  buyEventTicketWithToken();
                  break;
                case "GiftTicket":
                  giftEventTicket();
                  break;
              }
            } else {
              _getAvailablePayments();
            }
          }
        },
        child: Text(
          AppString.send.tr,
          style: TextStyles.textStyleSemiBold,
        ));
  }

  Future buyEventTicketWithToken() async {
    String accessToken = await LocalHiveStorage().getValue("access_token");
    setState(() {
      model['password'] = passwordTextController.text;
      isLoading = true;
    });

    final response = await CoreService().apiService(
        method: METHOD.POST,
        baseURL: GlobalKeys.BASE_URL,
        commonPoint: GlobalKeys.APIV1,
        endpoint: GlobalKeys.BUY_EVENT_TICKET,
        body: model,
        header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      Get.offAll(() => HomeScreen());
      Get.to(() => MyTickets());
    } else {
      String message = response["message"];
      return Fluttertoast.showToast(
          msg: message.tr,
          backgroundColor: Colors.black,
          textColor: Colors.white);
    }
  }

  Future giftEventTicket() async {
    String accessToken = await LocalHiveStorage().getValue("access_token");
    setState(() {
      model['password'] = passwordTextController.text;
      isLoading = true;
    });

    final response = await CoreService().apiService(
        method: METHOD.POST,
        baseURL: GlobalKeys.BASE_URL,
        commonPoint: GlobalKeys.APIV1,
        endpoint: GlobalKeys.GIFT_EVENT_TICKET,
        body: model,
        header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      Get.offAll(() => HomeScreen());
      Get.to(() => MyTickets());
    } else {
      String message = response["message"];
      return Fluttertoast.showToast(
          msg: message.tr,
          backgroundColor: Colors.black,
          textColor: Colors.white);
    }
  }

  _getAvailablePayments() async {
    setState(() {
      isLoading = true;
    });
    var result;
    if (widget.userId.toString().isNotEmpty) {
      result = await service.transferTosToken(passwordTextController.text,
          widget.tosToken, widget.userId.toString());
    } else {
      ShareStore().saveData(store: KeyStore.Amount, object: widget.tosToken);
      ShareStore().saveData(
          store: KeyStore.Password, object: passwordTextController.text);
      result =
          await service.getAvailablePaymentMethods(passwordTextController.text);
    }

    setState(() {
      isLoading = false;
    });

    if (result != null) {
      if (result["status"] == "success") {
        print("Success");
        PaymentAccountListModel model =
            PaymentAccountListModel.fromJson(result);
        print("Url:${model.url}");
        if (widget.userId.toString().isNotEmpty) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => TransactionSuccessful(transfer: true)));
        } else {
          ShareStore().saveData(store: KeyStore.PaymentMethods, object: result);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => PaymentModes()));
          /* model.url.isNotEmpty
              ? getBrowser(url: model.url, context: context)
              : Fluttertoast.showToast(
                  gravity: ToastGravity.BOTTOM,
                  msg: model.message.tr,
                  backgroundColor: CustomColor.myCustomBlack,
                  textColor: Colors.white);*/
        }
      } else if (result["status"] == "failure") {
        String error = result["error"];
        Fluttertoast.showToast(
            gravity: ToastGravity.BOTTOM,
            msg: error.tr,
            backgroundColor: CustomColor.myCustomBlack,
            textColor: Colors.white);
      }
    }
  }

  getBrowser({required String url, required BuildContext context}) async {
    Navigator.of(context).pop();
    await MyChromeSafariBrowser().open(
        url: Uri.parse(url),
        options: ChromeSafariBrowserClassOptions(
            android: AndroidChromeCustomTabsOptions(
                addDefaultShareMenuItem: false, keepAliveEnabled: true),
            ios: IOSSafariOptions(
                dismissButtonStyle: IOSSafariDismissButtonStyle.CLOSE,
                presentationStyle:
                    IOSUIModalPresentationStyle.OVER_CURRENT_CONTEXT)));
  }
}

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad() {
    print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() async {
    await Navigator.pushReplacement(ShareStore().getContext()!,
        MaterialPageRoute(builder: (context) => Wallet()));
    print("ChromeSafari browser closed");
  }
}
