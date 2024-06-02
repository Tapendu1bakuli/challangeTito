import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:titosapp/util/Assets.dart';
import 'package:titosapp/util/CustomColor.dart';

import '../util/TextStyles.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subTitle;
  final String price;
  final String status;
  final TextStyle? statusTextStyle;
  final onTap;
  final bool isGifted;

  ProductCard(
      {Key? key,
      this.imageUrl =
          "https://via.placeholder.com/500.png/09f/fffC/O https://placeholder.com/",
      this.title = "",
      this.subTitle = "",
      this.price = "",
      this.status = "",
      this.onTap,
      this.statusTextStyle,
      this.isGifted = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
          height: 114,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width / 30),
          decoration: BoxDecoration(
              border: Border.all(
                color: isGifted ? CustomColor.orange : CustomColor.colorGrey,
              ),
              color: CustomColor.colorGrey,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Row(
            children: [
              Container(
                //padding: EdgeInsets.all(12.5),
                height: 85,
                width: 85,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                    color: CustomColor.myCustomYellow,
                  )),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                decoration: BoxDecoration(
                    /*image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),*/
                    //color: CustomColor.CustomBlack,
                    /*border: Border.all(
                      color: CustomColor.myCustomBlack,
                    ),*/
                    //color: CustomColor.ProductTileColor,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 30,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyles.textStyleCardTitle,
                    ),
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
                          subTitle,
                          style: TextStyles.textStyleCardSubTitle,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          price,
                          style: TextStyles.textStyleCardSubTitle,
                        ),
                        status.isEmpty
                            ? Offstage()
                            : Expanded(
                                child: Text(
                                status,
                                style: statusTextStyle,
                                textAlign: TextAlign.right,
                              )),
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
