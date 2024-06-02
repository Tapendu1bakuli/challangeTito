// ignore_for_file: unnecessary_statements

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_quill/flutter_inappwebview_quill.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/Store/ShareStore.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';
import 'package:titosapp/widgets/Loader.dart';

import '../../apiService/MediaServices.dart';
import '../../model/PaymentMethodsModel.dart';
import '../../model/payment/PaymentAccountListModel.dart';
import '../InAppWebView/webview_screen.dart';
import '../wallet/Wallet.dart';

class PaymentModes extends StatefulWidget {
  @override
  PaymentModesState createState() => new PaymentModesState();
}

class PaymentModesState extends State<PaymentModes> {
  bool isLoading = false;

  late PaymentMethodsModel methodsModel;
  MediaService service = MediaService();

  _buyToken(gateway) async {
    setState(() {
      isLoading = true;
    });
    var result;

    result = await service.buyTosToken(
        tosToken: ShareStore().getData(store: KeyStore.Amount).toString(),
        password: ShareStore().getData(store: KeyStore.Password).toString(),
        gateway: gateway);

    setState(() {
      isLoading = false;
    });

    if (result != null) {
      if (result["status"] == "success") {
        print("Success");
        PaymentAccountListModel model =
            PaymentAccountListModel.fromJson(result);
        print("Url:${model.url}");
        if (model.url.isNotEmpty) {
          Navigator.of(context).pop();
          Get.off(() => WebViewScreen(
                webUrl: model.url,
                onBack: () async {
                  await Navigator.pushReplacement(ShareStore().getContext()!,
                      MaterialPageRoute(builder: (context) => Wallet()));
                },
              ));
        } else {
          Fluttertoast.showToast(
              gravity: ToastGravity.BOTTOM,
              msg: model.message.tr,
              backgroundColor: CustomColor.myCustomBlack,
              textColor: Colors.white);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CustomColor.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            AppString.payment.tr,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
          leading: IconButton(
            icon: new Icon(
              Icons.arrow_back_ios,
              color: CustomColor.myCustomYellow,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          physics: ClampingScrollPhysics(),
          children: [
            Stack(
              children: [
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 35, 0, 25),
                      alignment: Alignment.center,
                      child: Text(
                        AppString.payment_additional_text.tr,
                        style: TextStyles.textStyleSemiBold
                            .apply(color: CustomColor.colorTextHint),
                      ),
                    ),
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.all(0),
                      itemCount: methodsModel.data.length,
                      itemBuilder: (BuildContext ctxt, int index) => Column(
                        children: [
                          ListTile(
                            onTap: () {
                              _buyToken(
                                  methodsModel.data[index].method.toString());
                            },
                            leading: CachedNetworkImage(
                              width: 50,
                              height: 50,
                              imageUrl: methodsModel.data[index].url,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                margin: EdgeInsets.all(8),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                color: CustomColor.colorYellow,
                              )),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            title: Text(
                              methodsModel.data[index].method.toString(),
                              style: TextStyles.textStyleRegular,
                            ),
                            subtitle: Text(
                              methodsModel.data[index].avlPaymentMethod
                                  .toString(),
                              style: TextStyles.textStyleLight,
                            ),
                          ),
                        ],
                      ),
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                          indent: 20,
                          endIndent: 20,
                          color: CustomColor.colorDividerPayment,
                        );
                      },
                    ),
                    SizedBox(height: 40),
                    // if (mobileMoney.length>0)
                  ],
                ),
                Visibility(
                  child: Loader(),
                  visible: isLoading,
                )
              ],
            )
          ],
        ));
  }

  getAccountTypes() async {
    methodsModel = PaymentMethodsModel.fromJson(ShareStore()
        .getData(store: KeyStore.PaymentMethods) as Map<String, dynamic>);
  }

  @override
  void initState() {
    getAccountTypes();
    super.initState();
  }

  snackBar(String? message) {
    return Fluttertoast.showToast(
        msg: message!.tr,
        backgroundColor: Colors.black,
        textColor: Colors.white);
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
