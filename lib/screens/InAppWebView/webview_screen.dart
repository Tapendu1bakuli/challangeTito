import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../util/CustomColor.dart';

class WebViewScreen extends StatefulWidget {
  final String? webUrl;
  Function()? onBack;

  WebViewScreen({
    this.webUrl,
    this.onBack,
  });

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          // title: Text(
          //   AppString.payment.tr,
          //   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          // ),
          iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
          leading: IconButton(
            icon: new Icon(
              Icons.arrow_back_ios,
              color: CustomColor.myCustomYellow,
            ),
            onPressed: widget.onBack,
          ),
        ),
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: widget.webUrl,
          zoomEnabled: true,
          onPageStarted: (String url) {
            print("onPageStarted url : $url");
            // if (url.contains(widget.successUrl!)) {
            //   // Get.offAll(OrderPlacedScreen(
            //   //   oderId: widget.orderCode,
            //   // ));
            //   Get.offAllNamed(home);
            //   Get.snackbar("Success!", "Exam register successfully",
            //       backgroundColor: Colors.white,
            //       icon: const Icon(
            //         Icons.error_outline_sharp,
            //         color: Colors.red,
            //       ));
            // }
          },
          navigationDelegate: (NavigationRequest request) {
            // print('allowing navigation to $request');
            // if (request.url.startsWith(widget.successUrl!)) {
            //   // Get.offAll(OrderPlacedScreen(
            //   //   oderId: widget.orderCode,
            //   // ));
            //   Future.delayed(const Duration(seconds: 2), () {
            //     Get.offAllNamed(home);
            //   });

            //   Get.showSnackbar(const GetSnackBar(
            //     snackPosition: SnackPosition.BOTTOM,
            //     message: "Success, Exam register successfully",
            //     duration: Duration(seconds: 2),
            //     margin: EdgeInsets.only(bottom: 20, left: 10, right: 10),
            //   ));
            // }
            // // if (request.url.startsWith(widget.failedUrl!)) {
            // //   Get.back();
            // //   Get.snackbar("Sorry!", "Payment failed",
            // //       backgroundColor: Colors.white,
            // //       icon: const Icon(
            // //         Icons.error_outline_sharp,
            // //         color: Colors.red,
            // //       ));
            // // }
            return NavigationDecision.navigate;
          },
          onPageFinished: (String url) {
            print("onPageFinished url : $url");
            // if (url.contains(widget.failedUrl ?? "")) {
            //   Get.back();
            // }
          },
        ),
      ),
    );
  }
}
