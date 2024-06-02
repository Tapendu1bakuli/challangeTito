// ignore_for_file: unused_field

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../apiService/MediaServices.dart';
import '../../model/Event/BuyTicketSendModel.dart';
import '../../model/Event/EventListResponseModel.dart';
import '../../util/AppString.dart';
import '../../util/CustomColor.dart';
import '../../util/TextStyles.dart';
import '../../widgets/Loader.dart';
import '../InAppWebView/webview_screen.dart';
import '../transaction/BuyToken.dart';
import '../transaction/ValidateTransaction.dart';

class EventDetails extends StatefulWidget {
  final Events eventData;

  EventDetails({Key? key, required this.eventData}) : super(key: key);

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  late Events _eventData;
  late List<TextEditingController> textControllerList =
      <TextEditingController>[];

  String totalSeat = "0";

  String totalTos = "0";

  bool isLoading = false;
  num _balance = 0;
  num _tosToken = 0;
  String _walletId = "";
  num _usd = 0;
  num minTopUp = 0;
  num maxTopUp = 0;
  num minTransfer = 0;
  num maxTransfer = 0;

  _fetchWalletDetails() async {
    setState(() {
      isLoading = true;
    });
    var parsed = await MediaService().getWalletDetails();

    if (parsed != null) {
      _balance = parsed["wallet_ballence"];
      _tosToken = parsed["tos_token"];
      _walletId = parsed["Wallet ID"];
      _usd = parsed["usd"];
      maxTransfer = int.parse(parsed["max_transfer"].toString());
      minTransfer = int.parse(parsed["min_transfer"].toString());
      maxTopUp = int.parse(parsed["max_topup"].toString());
      minTopUp = int.parse(parsed["min_topup"].toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWalletDetails();
    _eventData = widget.eventData;
    for (int i = 0; i < _eventData.category.length; i++) {
      textControllerList.add(TextEditingController());
      textControllerList[i].text = "0";
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (int i = 0; i < _eventData.category.length; i++) {
      textControllerList[i].dispose();
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: CustomColor.myCustomYellow,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      backgroundColor: Colors.black,
      centerTitle: true,
      title: Text(
        _eventData.title,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.textStyleSemiBoldYellow,
      ),
      iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
      bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: [
                  Text(
                    _eventData.artistName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.textStyleSemiBoldWhite,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.width / 20,
                  ),
                  Text(
                    _eventData.venue,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.textStyleSemiBoldWhite,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.width / 20,
                  ),
                ],
              ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(context),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          color: Colors.black,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 6.4,
          child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 8),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       Text(
                  //         "$totalTos ${AppString.tos.tr}",
                  //         overflow: TextOverflow.ellipsis,
                  //         style: TextStyles.textStyleSemiBold,
                  //       ),
                  //       Row(
                  //         children: [
                  //           Text(
                  //             "${AppString.seat.tr} : ",
                  //             overflow: TextOverflow.ellipsis,
                  //             style: TextStyles.textStyleSemiBold,
                  //           ),
                  //           Text(
                  //             totalSeat,
                  //             overflow: TextOverflow.ellipsis,
                  //             style: TextStyles.textStyleSemiBold,
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Container(
                    height: 40,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: buyEventTicket,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)), backgroundColor: CustomColor.colorYellow,
                        minimumSize:
                            Size(MediaQuery.of(context).size.width, 50),
                      ),
                      child: Text(
                        AppString.buyNow.tr,
                        style: TextStyles.textStyleSemiBold
                            .apply(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              )),
        ),
        body: Stack(
          children: [
            ListView(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              children: [
                CachedNetworkImage(
                  height: MediaQuery.of(context).size.height / 4,
                  imageUrl: _eventData.thumbnail,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.fill),
                    ),
                  ),
                  placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                    color: CustomColor.colorYellow,
                  )),
                  errorWidget: (context, url, error) =>
                      Center(child: Icon(Icons.error)),
                ),
                Container(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _eventData.dateOfEvent,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.textStyleRegular,
                      ),
                      Text(
                        _eventData.eventCode,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.textStyleRegular,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    height: 2,
                    color: CustomColor.colorDividerPayment,
                  ),
                ),
                Container(
                  height: 20,
                ),
                // Scrollbar(
                //   child: ListView.separated(
                //     padding: EdgeInsets.symmetric(horizontal: 15),
                //     shrinkWrap: true,
                //     physics: const ClampingScrollPhysics(),
                //     itemCount: _eventData.category.length,
                //     itemBuilder: (context, i) {
                //       return Container(
                //         padding: EdgeInsets.all(15),
                //         decoration: BoxDecoration(
                //             color: CustomColor.colorBorderSearch,
                //             borderRadius: BorderRadius.circular(5),
                //             border: Border.all(
                //                 color: CustomColor.colorBorderSearch)),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             Text(
                //               _eventData.category[i].name,
                //               overflow: TextOverflow.ellipsis,
                //               style: TextStyles.textStyleSemiBoldBack,
                //             ),
                //             Column(
                //               children: [
                //                 _eventData.category[i].availableSeatForBooking >
                //                         0
                //                     ? NumericStepButton(
                //                         onPlus: () {
                //                           setState(() {
                //                             if (_eventData.category[i]
                //                                         .availableSeatForBooking >
                //                                     0 &&
                //                                 int.parse(textControllerList[i]
                //                                         .text) <
                //                                     _eventData.category[i]
                //                                         .availableSeatForBooking) {
                //                               totalTos = (int.parse(totalTos) +
                //                                       _eventData.category[i]
                //                                           .perSeatTos)
                //                                   .toString();
                //                               totalSeat =
                //                                   (int.parse(totalSeat) + 1)
                //                                       .toString();
                //                             } else {
                //                               Fluttertoast.showToast(
                //                                   msg: AppString
                //                                       .noAvailableSeat.tr,
                //                                   backgroundColor: Colors.black,
                //                                   textColor: Colors.white);
                //                             }
                //                           });
                //                         },
                //                         onMinus: () {
                //                           setState(() {
                //                             if (int.parse(textControllerList[i]
                //                                     .text) >
                //                                 0) {
                //                               totalTos = (int.parse(totalTos) -
                //                                       _eventData.category[i]
                //                                           .perSeatTos)
                //                                   .toString();
                //                               totalSeat =
                //                                   (int.parse(totalSeat) - 1)
                //                                       .toString();
                //                             } /* else {
                //                           Fluttertoast.showToast(
                //                               msg: AppString.addSomeSeats.tr,
                //                               backgroundColor: Colors.black,
                //                               textColor: Colors.white);
                //                         }*/
                //                           });
                //                         },
                //                         textEditingController:
                //                             textControllerList[i],
                //                         minValue: 0,
                //                         maxValue: _eventData.category[i]
                //                             .availableSeatForBooking)
                //                     : Container(
                //                         decoration: BoxDecoration(
                //                           color: CustomColor.myCustomBlack,
                //                           borderRadius:
                //                               BorderRadius.circular(8.0),
                //                         ),
                //                         padding: EdgeInsets.all(10),
                //                         child: Text(AppString.soldOut.tr,
                //                             style: TextStyles
                //                                 .textStyleSemiBoldYellow)),
                //                 Container(
                //                   height: 10,
                //                 ),
                //                 Text(
                //                   "${_eventData.category[i].perSeatTos} ${AppString.tosPerSeat.tr}",
                //                   overflow: TextOverflow.ellipsis,
                //                   style: TextStyles.textStyleRegular,
                //                 ),
                //               ],
                //             ),
                //           ],
                //         ),
                //       );
                //     },
                //     separatorBuilder: (BuildContext context, int index) {
                //       return Container(
                //         height: 10,
                //       );
                //     },
                //   ),
                // )
              ],
            ),
            Visibility(
              child: Loader(),
              visible: isLoading,
            )
          ],
        ));
  }

  void buyEventTicket() async {
    if (_eventData.paymentUrlStatus) {
      Get.to(() => WebViewScreen(
            webUrl: _eventData.paymentUrl,
            onBack: () {
              Get.back();
            },
          ));
    } else {
      if (int.parse(totalSeat) > 0) {
        if (int.parse(totalTos) > _balance) {
          Get.to(() => BuyToken());
        } else {
          late List<TicketInfos> ticketInfo = <TicketInfos>[];
          textControllerList.asMap().forEach((idx, element) {
            if (int.parse(element.text) > 0)
              ticketInfo.add(TicketInfos(
                requestNoOfSeats: int.parse(element.text),
                seatCategoryId: _eventData.category[idx].seatCategoryId,
                tosAmount: _eventData.category[idx].perSeatTos *
                    int.parse(element.text),
              ));
          });

          BuyTicketSendModel model = BuyTicketSendModel(
              eventManagementId: _eventData.eventManagementId,
              ticketInfos: ticketInfo);
          print("Model Data: ${model.toJson()}");
          Get.to(() => ValidateTransaction(
                page: "BuyTicket",
                model: model.toJson(),
              ));
        }
      }
    }
  }
}
