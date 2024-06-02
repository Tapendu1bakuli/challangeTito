import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:titosapp/screens/Events/ticket_card.dart';
import 'package:titosapp/screens/dashboard/MyTickets.dart';
import 'package:titosapp/util/AppString.dart';

import '../../model/Event/MyTIcketsResponseModel.dart';
import '../../util/CustomColor.dart';
import '../../util/TextStyles.dart';
import '../../widgets/Loader.dart';
import 'TicketsTransfer.dart';
import 'package:intl/intl.dart';
class TicketDetails extends StatefulWidget {
  final Tickets ticketData;

  TicketDetails({Key? key, required this.ticketData}) : super(key: key);

  @override
  State<TicketDetails> createState() => _TicketDetailsState();
}

class _TicketDetailsState extends State<TicketDetails> {
  bool isLoading = false;

  late Tickets _ticketData;

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: CustomColor.myCustomYellow,
        ),
        onPressed: () {
          Get.back();
          Get.back();
          Get.to(()=>MyTickets());
        },
      ),
      backgroundColor: Colors.black,
      centerTitle: true,
      title: Text(
        AppString.ticketDetails.tr,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.textStyleSemiBoldWhite,
      ),
      iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
    );
  }

  @override
  void initState() {
    super.initState();
    _ticketData = widget.ticketData;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var parsedDate = DateFormat("dd MMM yyyy, hh:mm a").parse(_ticketData.purchaseDate);
    var now = new DateTime.now();
    var timezoneOffset = now.timeZoneOffset;
    parsedDate = parsedDate.add(timezoneOffset);
    var purchaseDate = DateFormat("dd MMM yyyy, hh:mm a").format(parsedDate);
    return Scaffold(
        appBar: _buildAppBar(context),
        bottomNavigationBar: _ticketData.ticketStatus == AppString.Booked
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 6.5,
                child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Get.to(() =>
                                TicketsTransfer(ticketData: widget.ticketData));
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)), backgroundColor: CustomColor.colorYellow,
                            minimumSize:
                                Size(MediaQuery.of(context).size.width, 50),
                          ),
                          child: Text(
                            AppString.MakeAGift.tr,
                            style: TextStyles.textStyleSemiBold
                                .apply(color: Colors.black),
                          ),
                        )
                      ],
                    )),
              )
            : Offstage(),
        body: Stack(
          children: [
            ListView(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Center(
                    child: Container(
                      //padding: EdgeInsets.all(12.5),
                      height: 170,
                      width: 170,
                      decoration: BoxDecoration(
                          //color: CustomColor.CustomBlack,
                          /*border: Border.all(
                            color: CustomColor.myCustomBlack,
                          ),*/
                          //color: CustomColor.ProductTileColor,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: CachedNetworkImage(
                        imageUrl: _ticketData.qrCode,
                        placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                          color: CustomColor.myCustomBlack,
                        )),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    _ticketData.ticketCode,
                    style: TextStyles.textStyleCardTitle,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(23),
                  child: TicketCard(
                    title: _ticketData.eventTitle,
                    subTitle:
                        "${AppString.Purchase.tr}: $purchaseDate",
                    price: "${_ticketData.amount} ${AppString.tos}",
                    expDate: "${AppString.Expired.tr}: ${_ticketData.expireOn}",
                    validityStatus: _ticketData.ticketStatus.tr,
                    categoryName: _ticketData.category,
                    categorySeat: _ticketData.numberOfSets.toString(),
                    senderName: _ticketData.senderName.toString(),
                    receiverName: _ticketData.receiverName.toString(),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 50,
                ),
                Center(
                  child: Text(
                    _ticketData.venue,
                    style: TextStyles.textStyleExtraBoldBlack,
                  ),
                ),
                Container(
                  height: 10,
                ),
                Center(
                  child: Text(
                    _ticketData.dateOfEvent,
                    style: TextStyles.textStyleCardSubTitle,
                  ),
                ),
                Container(
                  height: 10,
                ),
                Center(
                  child: Text(
                    _ticketData.artist,
                    style: TextStyles.textStyleExtraBoldBlack,
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.width / 6,
                ),
              ],
            ),
            Visibility(
              child: Loader(),
              visible: isLoading,
            )
          ],
        ));
  }
}
