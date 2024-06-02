import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:titosapp/screens/Events/TicketDetails.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/widgets/product_card.dart';

import '../../Service/CoreService.dart';
import '../../Service/GlobalKeys.dart';
import '../../model/Event/MyTIcketsResponseModel.dart';
import '../../util/CustomColor.dart';
import '../../util/TextStyles.dart';
import '../../util/localStorage.dart';
import '../../widgets/Loader.dart';

class MyTickets extends StatefulWidget {
  const MyTickets({Key? key}) : super(key: key);

  @override
  State<MyTickets> createState() => _MyTicketsState();
}

class _MyTicketsState extends State<MyTickets> {
  bool isLoading = false;
  late MyTicketsResponseModel ticketsResponseModel =
      MyTicketsResponseModel.empty();

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
        AppString.myTicket.tr,
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
    getMyTicketsList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(context),
        body: Stack(
          children: [
            ticketsResponseModel.data.tickets.length>0?Scrollbar(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: ticketsResponseModel.data.tickets.length,
                itemBuilder: (context, i) {
                  TextStyle dynamicStyle = TextStyles.textStyleCardSubTitle;
                  switch (ticketsResponseModel.data.tickets[i].ticketStatus) {
                    case AppString.Redeemed:
                      dynamicStyle = TextStyles.textStyleCardSubTitleBlue;
                      break;
                    case AppString.Gifted:
                      dynamicStyle = TextStyles.textStyleCardSubTitleOrange;
                      break;
                    case AppString.Booked:
                      dynamicStyle = TextStyles.textStyleCardSubTitleGreen;
                      break;
                    case AppString.Expired:
                      dynamicStyle = TextStyles.textStyleCardSubTitleRed;
                      break;
                    case "Utilisé":
                      dynamicStyle = TextStyles.textStyleCardSubTitle;

                      break;
                    case "Offert comme don":
                      dynamicStyle = TextStyles.textStyleCardSubTitleOrange;

                      break;
                    case "Réservé":
                      dynamicStyle = TextStyles.textStyleCardSubTitleGreen;

                      break;
                    case "Expiré":
                      dynamicStyle = TextStyles.textStyleCardSubTitleRed;

                      break;
                    case "사용됨":
                      dynamicStyle = TextStyles.textStyleCardSubTitle;

                      break;
                    case "선물보냈음":
                      dynamicStyle = TextStyles.textStyleCardSubTitleOrange;

                      break;
                    case "예약됨":
                      dynamicStyle = TextStyles.textStyleCardSubTitleGreen;

                      break;
                    case "만료됨":
                      dynamicStyle = TextStyles.textStyleCardSubTitleRed;

                      break;
                  }
                  return ProductCard(
                      title: ticketsResponseModel.data.tickets[i].artist,
                      imageUrl: ticketsResponseModel.data.tickets[i].qrCode,
                      onTap: () {
                        Get.to(() => TicketDetails(
                            ticketData: ticketsResponseModel.data.tickets[i]));
                      },
                      price:
                          "${ticketsResponseModel.data.tickets[i].amount} ${AppString.tos.tr}",
                      status: ticketsResponseModel.data.tickets[i].ticketStatus.tr,
                      statusTextStyle: dynamicStyle,
                      subTitle:
                          "${AppString.Expired.tr} :${ticketsResponseModel.data.tickets[i].expireOn}",
                      isGifted: ticketsResponseModel.data.tickets[i].ticketStatus == AppString.Gifted
                          ? true
                          : false);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 10,
                  );
                },
              ),
            ): Center(child: Text(AppString.noTicketFound.tr,style: TextStyles.textStyleSemiBoldBlack),),
            Visibility(
              child: Loader(),
              visible: isLoading,
            )
          ],
        ));
  }

  void getMyTicketsList() async {
    String accessToken = await LocalHiveStorage().getValue("access_token");
    setState(() {
      isLoading = true;
    });
    final String currentTimeZone =
    await FlutterNativeTimezone.getLocalTimezone();
    final response = await CoreService().apiService(
        method: METHOD.GET,
        baseURL: GlobalKeys.BASE_URL,
        commonPoint: GlobalKeys.APIV1,
        params: {"timezone": currentTimeZone},
        endpoint: GlobalKeys.MY_TICKETS,
        header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});
    setState(() {
      isLoading = false;
    });
    setState(() {
      ticketsResponseModel = MyTicketsResponseModel.fromJson(response);
    });
  }
}
