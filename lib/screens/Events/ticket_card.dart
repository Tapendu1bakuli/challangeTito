import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/Assets.dart';

import '../../util/CustomColor.dart';
import '../../util/TextStyles.dart';

class TicketCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final String expDate;
  final String price;
  final String status;
  final String validityStatus;
  final String loanStatus;
  final String categoryName;
  final String categorySeat;
  final String senderName;
  final String receiverName;

  final onTap;

  TicketCard(
      {Key? key,
      this.title = "",
      this.subTitle = "",
      this.price = "",
      this.status = "",
      this.onTap,
      this.expDate = "",
      this.validityStatus = "",
      this.categoryName = "",
      this.categorySeat = "",
      this.senderName = "",
      this.receiverName = "",
      this.loanStatus = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color dynamicStyle = CustomColor.colorBgHome;
    TextStyle dynamicTextStyle = TextStyles.textStyleCardSubTitle;

    switch (validityStatus) {
      case AppString.Redeemed:
        dynamicStyle = CustomColor.colorDiaBlue;
        dynamicTextStyle = TextStyles.textStyleSemiBold;
        break;
      case AppString.Gifted:
        dynamicStyle = CustomColor.orange;
        dynamicTextStyle = TextStyles.textStyleSemiBold;

        break;
      case AppString.Booked:
        dynamicStyle = CustomColor.green;
        dynamicTextStyle = TextStyles.textStyleSemiBold;

        break;
      case AppString.Expired:
        dynamicStyle = CustomColor.red;
        dynamicTextStyle = TextStyles.textStyleSemiBold;

        break;
      case "Utilisé":
        dynamicStyle = CustomColor.colorDiaBlue;
        dynamicTextStyle = TextStyles.textStyleSemiBold;
        break;
      case "Offert comme don":
        dynamicStyle = CustomColor.orange;
        dynamicTextStyle = TextStyles.textStyleSemiBold;

        break;
      case "Réservé":
        dynamicStyle = CustomColor.green;
        dynamicTextStyle = TextStyles.textStyleSemiBold;

        break;
      case "Expiré":
        dynamicStyle = CustomColor.red;
        dynamicTextStyle = TextStyles.textStyleSemiBold;

        break;
      case "사용됨":
        dynamicStyle = CustomColor.colorDiaBlue;
        dynamicTextStyle = TextStyles.textStyleSemiBold;
        break;
      case "선물보냈음":
        dynamicStyle = CustomColor.orange;
        dynamicTextStyle = TextStyles.textStyleSemiBold;

        break;
      case "예약됨":
        dynamicStyle = CustomColor.green;
        dynamicTextStyle = TextStyles.textStyleSemiBold;

        break;
      case "만료됨":
        dynamicStyle = CustomColor.red;
        dynamicTextStyle = TextStyles.textStyleSemiBold;

        break;

    }
    return InkWell(
      onTap: onTap,
      child: Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width / 30),
          decoration: BoxDecoration(
              border: Border.all(
                color: CustomColor.colorGrey,
              ),
              color: CustomColor.colorGrey,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 30,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.textStyleTitosCardTitle,
                          ),
                        ),
                        validityStatus.isEmpty
                            ? Offstage()
                            : Container(
                                padding: EdgeInsets.only(
                                    top: 4.0,
                                    bottom: 4.0,
                                    left: 5.0,
                                    right: 5.0),
                                decoration: new BoxDecoration(
                                    color: dynamicStyle,
                                    borderRadius: new BorderRadius.all(
                                      Radius.circular(20.0),
                                    )),
                                child: Center(
                                  child: Text(
                                    validityStatus,
                                    style: dynamicTextStyle,
                                  ),
                                )),
                      ],
                    ),
                    Container(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          Assets.calender,
                          fit: BoxFit.fill,
                          color: Colors.black,
                          height: 15,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 75,
                        ),
                        Text(
                          subTitle,
                          style: TextStyles.textStyleCardSubTitle,
                        ),
                      ],
                    ),
                    Container(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text(
                          price,
                          style: TextStyles.textStyleSemiBoldBlack,
                        ),
                        status.isEmpty
                            ? Offstage()
                            : Expanded(
                                child: Text(
                                status,
                                style: TextStyles.textStyleCardSubTitle,
                                textAlign: TextAlign.right,
                              )),
                      ],
                    ),
                    Container(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              Assets.calender,
                              fit: BoxFit.fill,
                              color: Colors.black,
                              height: 14,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 75,
                            ),
                            Text(
                              expDate,
                              style: TextStyles.textStyleCardSubTitle,
                            ),
                          ],
                        ),
                        loanStatus.isEmpty
                            ? Offstage()
                            : Text(
                                loanStatus,
                                style: TextStyles.textStyleCardSubTitle,
                              ),
                      ],
                    ),
                    Container(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "$categoryName : $categorySeat",
                            style: TextStyles.textStyleCardSubTitleOrange,
                          ),
                        ),
                        receiverName.isEmpty
                            ? Offstage()
                            : Flexible(
                                child: Text(
                                  "${AppString.to.tr} : $receiverName",
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: TextStyles.textStyleCardSubTitleOrange,
                                ),
                              ),
                        senderName.isEmpty
                            ? Offstage()
                            : Flexible(
                                child: Text(
                                  "${AppString.from.tr} : $senderName",
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: TextStyles.textStyleCardSubTitleOrange,
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
