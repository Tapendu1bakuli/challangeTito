import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:titosapp/model/Event/EventListResponseModel.dart';
import 'package:titosapp/screens/Events/SearchCity.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';

import '../../Service/CoreService.dart';
import '../../Service/GlobalKeys.dart';
import '../../model/CityList.dart';
import '../../util/TextStyles.dart';
import '../../util/localStorage.dart';
import '../../util/utils.dart';
import '../../widgets/CustomSearchTextField.dart';
import '../../widgets/Loader.dart';
import 'EventDetaiils.dart';

class EventsList extends StatefulWidget {
  const EventsList({Key? key}) : super(key: key);

  @override
  _EventsListState createState() => _EventsListState();
}

class _EventsListState extends State<EventsList>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  late TextEditingController _searchTextController = TextEditingController();
  late TextEditingController _searchGlobalTextController =
      TextEditingController();

  FocusNode focusNode = FocusNode();
  List<Events> eventList = <Events>[];
  CityList cityList = CityList(cities: [Cities(id: 0, name: AppString.all.tr)]);
  late Country countryData = Country.parse("WW");
  late Cities currentCity = Cities(id: 0, name: AppString.all.tr);
  List<Cities> _searchResult = <Cities>[];
  late num page = 1;
  String? city;
  List<Types> eventTypeList = <Types>[Types(id: 0, name: AppString.all.tr)];
  Types? selectedEventType;

  bool isGlobalEnable = false;

  num totalData = 0;

  bool loadMore = false;
  var now = new DateTime.now();

  @override
  void initState() {
    super.initState();
    getEvents(page: page).then((value) => getCities(countryData.countryCode));

    _searchTextController.addListener(() {
      if (_searchTextController.text.isEmpty) {
        return;
      }
      if (focusNode.hasFocus) {
        focusNode.unfocus();
      } else {
        focusNode.requestFocus();
      }
      if (_searchTextController.text.trim().isNotEmpty) {
        setState(() {
          _searchResult.clear();
          cityList.cities.forEach((city) {
            if (city.name.contains(_searchTextController.text))
              _searchResult.add(city);
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _searchGlobalTextController.dispose();
    super.dispose();
  }

  getCities(String countryCode) async {
    setState(() {
      isLoading = true;
    });
    final response = await CoreService().apiService(
        method: METHOD.GET,
        baseURL: GlobalKeys.CITY_BASE_URL,
        commonPoint: GlobalKeys.CITY_API_V1,
        endpoint: "$countryCode${GlobalKeys.CITY_END_POINT}",
        header: {"X-CSCAPI-KEY": GlobalKeys.APIKEY});
    setState(() {
      isLoading = false;
    });
    setState(() {
      if (List.from(response).isNotEmpty) {
        cityList = CityList(
            cities:
                List.from(response).map((e) => Cities.fromJson(e)).toList());
        currentCity = Cities(id: 0, name: AppString.all.tr);
      } else {
        cityList = CityList(cities: [Cities(id: 0, name: AppString.all.tr)]);
        currentCity = Cities(id: 0, name: AppString.all.tr);
      }
    });
  }

  showPicker() {
    return showCountryPicker(
        context: context,
        countryListTheme: CountryListThemeData(
          flagSize: 25,
          backgroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
          //Optional. Sets the border radius for the bottomsheet.
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          //Optional. Styles the search field.
          inputDecoration: InputDecoration(
            labelText: AppString.search.tr,
            hintText: AppString.type_search.tr,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: CustomColor.myCustomYellow,
              ),
            ),
          ),
        ),
        onSelect: (Country country) {
          setState(() {
            countryData = country;
            page = 1;
            getEvents(
                    cCode: countryData.countryCode,
                    city: currentCity.name,
                    eventTypeListFiltered: selectedEventType?.id.toString(),
                    page: page,
                    text: _searchGlobalTextController.text)
                .then((value) => getCities(countryData.countryCode));
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(context),
        body: GestureDetector(
          onTap: () => dismissKeyboard(context),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        showPicker();
                      },
                      child: ListView(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        children: [
                          Row(
                            children: [
                              Text(countryData.flagEmoji,
                                  style: TextStyles.textStyleSemiBoldIcon),
                              Container(
                                width: 2,
                              ),
                              Text(countryData.name,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: TextStyles.textStyleSemiBoldBack),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(height: 2, color: CustomColor.colorDividerPayment),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomSearchTextField(
                            fillColor: CustomColor.colorGrey,
                            icon: Icons.my_location,
                            hintText: currentCity.name,
                            textController: _searchTextController,
                            focusNode: focusNode,
                            readOnly: true,
                            onWidgetPressed: () {
                              return showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.80,
                                  decoration: new BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: new BorderRadius.only(
                                      topLeft: const Radius.circular(25.0),
                                      topRight: const Radius.circular(25.0),
                                    ),
                                  ),
                                  child: SearchCity(
                                    allCityList: cityList.cities,
                                    currentCity: currentCity,
                                    callBackChange: callBackChange,
                                  ),
                                ),
                              );
                            },
                            onTap: () {
                              if (_searchTextController.text.isEmpty) {
                                return;
                              }
                              if (focusNode.hasFocus) {
                                focusNode.unfocus();
                              } else {
                                focusNode.requestFocus();
                              }
                              if (_searchTextController.text
                                  .trim()
                                  .isNotEmpty) {}
                            },
                            isLoading: isLoading,
                          ),
                        ),
                        Visibility(
                          visible: currentCity.id == 0 ? false : true,
                          child: InkWell(
                              onTap: () {
                                setState(() {
                                  currentCity =
                                      Cities(id: 0, name: AppString.all.tr);
                                  getEvents(
                                      cCode: countryData.countryCode,
                                      city: currentCity.name,
                                      eventTypeListFiltered:
                                          selectedEventType?.id.toString(),
                                      page: page,
                                      text: _searchGlobalTextController.text);
                                });
                              },
                              child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2),
                                  child: Icon(Icons.clear_all_rounded))),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0, right: 0.0),
                        child: Text(
                            "${AppString.events.tr} (${eventList.length})",
                            style: TextStyles.textStyleRegular),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            isGlobalEnable
                                ? Container(
                                    height:
                                        MediaQuery.of(context).size.width / 11,
                                    width: 180,
                                    child: Row(children: [
                                      Expanded(
                                        child: CustomSearchTextField(
                                          fillColor: CustomColor.colorGrey,
                                          icon: Icons.search,
                                          hintText: AppString.search.tr,
                                          textController:
                                              _searchGlobalTextController,
                                          focusNode: focusNode,
                                          readOnly: isLoading ? true : false,
                                          onTap: () {
                                            if (_searchGlobalTextController
                                                .text.isEmpty) {
                                              return;
                                            }
                                            if (focusNode.hasFocus) {
                                              focusNode.unfocus();
                                            } else {
                                              focusNode.requestFocus();
                                            }
                                            if (_searchGlobalTextController.text
                                                .trim()
                                                .isNotEmpty) {
                                              setState(() {
                                                page = 1;
                                              });
                                              getEvents(
                                                  cCode:
                                                      countryData.countryCode,
                                                  city: currentCity.name,
                                                  eventTypeListFiltered:
                                                      selectedEventType?.id
                                                          .toString(),
                                                  page: page,
                                                  text:
                                                      _searchGlobalTextController
                                                          .text);
                                            }
                                          },
                                          isLoading: isLoading,
                                        ),
                                      ),
                                      InkWell(
                                          onTap: () {
                                            setState(() {
                                              _searchGlobalTextController
                                                  .clear();
                                              isGlobalEnable = false;
                                              page = 1;
                                              getEvents(
                                                  cCode:
                                                      countryData.countryCode,
                                                  city: currentCity.name,
                                                  eventTypeListFiltered:
                                                      selectedEventType?.id
                                                          .toString(),
                                                  page: page,
                                                  text:
                                                      _searchGlobalTextController
                                                          .text);
                                            });
                                          },
                                          child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 2),
                                              child: Icon(
                                                  Icons.clear_all_rounded)))
                                    ]),
                                  )
                                : InkWell(
                                    onTap: () {
                                      setState(() {
                                        isGlobalEnable = true;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 18.0,
                                      ),
                                      child: Icon(Icons.search, size: 16),
                                    ),
                                  ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 27.0),
                              child: DropdownButton<Types>(
                                underline: Container(
                                  height: 0,
                                ),
                                icon: Visibility(
                                    visible: false,
                                    child: Icon(Icons.arrow_downward)),
                                items: eventTypeList.map((Types value) {
                                  return DropdownMenuItem<Types>(
                                    value: value,
                                    child: Text(value.name,
                                        style: TextStyles.textStyleRegular),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedEventType = val!;
                                    page = 1;
                                    getEvents(
                                        cCode: countryData.countryCode,
                                        city: currentCity.name,
                                        eventTypeListFiltered:
                                            selectedEventType?.id.toString(),
                                        page: page,
                                        text: _searchGlobalTextController.text);
                                  });
                                },
                                value: selectedEventType,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 10.0,
                  ),
                  Expanded(
                    flex: 11,
                    child: eventList.length > 0
                        ? ListView(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            children: [
                              Scrollbar(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: eventList.length > 0
                                      ? eventList.length < totalData
                                          ? eventList.length + 1
                                          : eventList.length
                                      : 0,
                                  itemBuilder: (context, i) {
                                    return (i == eventList.length &&
                                            eventList.length < totalData)
                                        ? Container(
                                            padding:
                                                EdgeInsets.only(bottom: 20),
                                            height: 60,
                                            child: Center(
                                              child: loadMore
                                                  ? CircularProgressIndicator()
                                                  : InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          page = ++page;
                                                        });
                                                        loadMoreEvents(
                                                            cCode: countryData
                                                                .countryCode,
                                                            city: currentCity
                                                                .name,
                                                            eventTypeListFiltered:
                                                                selectedEventType
                                                                    ?.id
                                                                    .toString(),
                                                            page: page,
                                                            text:
                                                                _searchGlobalTextController
                                                                    .text);
                                                      },
                                                      child: Text(
                                                        AppString.loadMore.tr,
                                                        softWrap: true,
                                                        style: TextStyles
                                                            .textStyleSemiBoldBack,
                                                      ),
                                                    ),
                                            ))
                                        : Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: CustomColor
                                                        .colorBorderSearch)),
                                            child: Stack(
                                              children: [
                                                CachedNetworkImage(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      5,
                                                  imageUrl:
                                                      eventList[i].thumbnail,
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      Container(
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.fill),
                                                    ),
                                                  ),
                                                  placeholder: (context, url) =>
                                                      Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                    color:
                                                        CustomColor.colorYellow,
                                                  )),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Center(
                                                              child: Icon(
                                                                  Icons.error)),
                                                ),
                                                if (DateTime.parse(eventList[i]
                                                            .ticketBookingStart)
                                                        .isBefore(now) &&
                                                    DateTime.parse(eventList[i]
                                                            .ticketBookingEnd)
                                                        .isAfter(now))
                                                  eventList[i].totalSeatAvailable ==
                                                          0
                                                      ? Positioned(
                                                          right: 20,
                                                          top: 23,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: CustomColor
                                                                  .myCustomBlack,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .blueAccent),
                                                              borderRadius:
                                                                  BorderRadius.all(
                                                                      Radius.circular(
                                                                          5.0) //                 <--- border radius here
                                                                      ),
                                                            ),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        20),
                                                            child: Text(
                                                                AppString
                                                                    .soldOut
                                                                    .toUpperCase()
                                                                    .tr,
                                                                style: TextStyles
                                                                    .textStyleBold),
                                                          ))
                                                      : Offstage()
                                                else
                                                  DateTime.parse(eventList[i]
                                                              .ticketBookingEnd)
                                                          .isBefore(now)
                                                      ? Positioned(
                                                          right: 20,
                                                          top: 23,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: CustomColor
                                                                  .myCustomBlack,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .blueAccent),
                                                              borderRadius:
                                                                  BorderRadius.all(
                                                                      Radius.circular(
                                                                          5.0) //                 <--- border radius here
                                                                      ),
                                                            ),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        20),
                                                            child: Text(
                                                                AppString
                                                                    .promotionalClosed
                                                                    .toUpperCase()
                                                                    .tr,
                                                                style: TextStyles
                                                                    .textStyleBold),
                                                          ))
                                                      : Positioned(
                                                          right: 20,
                                                          top: 23,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: CustomColor
                                                                  .myCustomBlack,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .blueAccent),
                                                              borderRadius:
                                                                  BorderRadius.all(
                                                                      Radius.circular(
                                                                          5.0) //                 <--- border radius here
                                                                      ),
                                                            ),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        20),
                                                            child: Text(
                                                                AppString
                                                                    .promotional
                                                                    .toUpperCase()
                                                                    .tr,
                                                                style: TextStyles
                                                                    .textStyleBold),
                                                          )),
                                                Positioned(
                                                    left: 69,
                                                    right: 69,
                                                    bottom: 23,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        if (DateTime.parse(
                                                                    eventList[i]
                                                                        .ticketBookingStart)
                                                                .isBefore(
                                                                    now) &&
                                                            DateTime.parse(
                                                                    eventList[i]
                                                                        .ticketBookingEnd)
                                                                .isAfter(now)) {
                                                          Get.to(() =>
                                                              EventDetails(
                                                                  eventData:
                                                                      eventList[
                                                                          i]));
                                                        } else {
                                                          Get.bottomSheet(
                                                            ListView(
                                                              shrinkWrap: true,
                                                              physics:
                                                                  ClampingScrollPhysics(),
                                                              children: [
                                                                CachedNetworkImage(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      4,
                                                                  imageUrl:
                                                                      eventList[
                                                                              i]
                                                                          .thumbnail,
                                                                  imageBuilder:
                                                                      (context,
                                                                              imageProvider) =>
                                                                          Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      image: DecorationImage(
                                                                          image:
                                                                              imageProvider,
                                                                          fit: BoxFit
                                                                              .fill),
                                                                    ),
                                                                  ),
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      Center(
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                    color: CustomColor
                                                                        .colorYellow,
                                                                  )),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Center(
                                                                          child:
                                                                              Icon(Icons.error)),
                                                                ),
                                                                Container(
                                                                  height: 20,
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        eventList[i]
                                                                            .dateOfEvent,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyles
                                                                            .textStyleRegular,
                                                                      ),
                                                                      Text(
                                                                        eventList[i]
                                                                            .eventCode,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyles
                                                                            .textStyleRegular,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  height: 20,
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                  child:
                                                                      Container(
                                                                    height: 2,
                                                                    color: CustomColor
                                                                        .colorDividerPayment,
                                                                  ),
                                                                ),
                                                                Container(
                                                                  height: 20,
                                                                ),
                                                                // Scrollbar(
                                                                //   child: ListView
                                                                //       .separated(
                                                                //     padding: EdgeInsets.symmetric(
                                                                //         horizontal:
                                                                //             15),
                                                                //     shrinkWrap:
                                                                //         true,
                                                                //     physics:
                                                                //         const ClampingScrollPhysics(),
                                                                //     itemCount: eventList[
                                                                //             i]
                                                                //         .category
                                                                //         .length,
                                                                //     itemBuilder:
                                                                //         (context,
                                                                //             ind) {
                                                                //       return Container(
                                                                //         padding:
                                                                //             EdgeInsets.all(15),
                                                                //         decoration: BoxDecoration(
                                                                //             color:
                                                                //                 CustomColor.colorBorderSearch,
                                                                //             borderRadius: BorderRadius.circular(5),
                                                                //             border: Border.all(color: CustomColor.colorBorderSearch)),
                                                                //         child:
                                                                //             Row(
                                                                //           mainAxisAlignment:
                                                                //               MainAxisAlignment.spaceBetween,
                                                                //           children: [
                                                                //             Text(
                                                                //               eventList[i].category[ind].name,
                                                                //               overflow: TextOverflow.ellipsis,
                                                                //               style: TextStyles.textStyleSemiBoldBack,
                                                                //             ),
                                                                //             Column(
                                                                //               children: [
                                                                //                 Text(
                                                                //                   "${eventList[i].category[ind].perSeatTos} ${AppString.tosPerSeat.tr}",
                                                                //                   overflow: TextOverflow.ellipsis,
                                                                //                   style: TextStyles.textStyleRegular,
                                                                //                 ),
                                                                //               ],
                                                                //             ),
                                                                //           ],
                                                                //         ),
                                                                //       );
                                                                //     },
                                                                //     separatorBuilder:
                                                                //         (BuildContext
                                                                //                 context,
                                                                //             int index) {
                                                                //       return Container(
                                                                //         height:
                                                                //             10,
                                                                //       );
                                                                //     },
                                                                //   ),
                                                                // ),
                                                                // Container(
                                                                //   height: 20,
                                                                // ),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              20),
                                                                  child: ElevatedButton(
                                                                      onPressed: () {
                                                                        Get.back();
                                                                      },
                                                                      style: ElevatedButton.styleFrom(
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10)), backgroundColor: CustomColor.colorYellow,
                                                                        minimumSize: Size(
                                                                            MediaQuery.of(context).size.width,
                                                                            50),
                                                                      ),
                                                                      child: Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            10.0),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Text(
                                                                              "${AppString.bookingStartAfter.tr} : ${DateFormat(
                                                                                'd MMM y hh:mm a',
                                                                              ).format(DateTime.parse(eventList[i].ticketBookingStart))}",
                                                                              style: TextStyles.textStyleSemiBold.apply(color: Colors.black),
                                                                            ),
                                                                            Container(
                                                                              height: 10,
                                                                            ),
                                                                            Text(
                                                                              "${AppString.bookingEndAfter.tr} : ${DateFormat(
                                                                                'd MMM y hh:mm a',
                                                                              ).format(DateTime.parse(eventList[i].ticketBookingEnd))}",
                                                                              style: TextStyles.textStyleSemiBold.apply(color: Colors.black),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      )),
                                                                ),
                                                              ],
                                                            ),
                                                            isScrollControlled:
                                                                true,
                                                            backgroundColor:
                                                                CustomColor
                                                                    .white,
                                                          );
                                                        }
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)), backgroundColor: CustomColor
                                                            .colorYellow,
                                                        minimumSize: Size(
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width,
                                                            50),
                                                      ),
                                                      child: Text(
                                                        eventList[i].artistName,
                                                        style: TextStyles
                                                            .textStyleSemiBold
                                                            .apply(
                                                                color: Colors
                                                                    .black),
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          );
                                  },
                                ),
                              )
                            ],
                          )
                        : Container(
                            child: Center(
                                child: Text(
                              AppString.noEventsFound.tr,
                              style: TextStyles.textStyleSemiBoldBlack,
                            )),
                          ),
                  ),
                ],
              ),
              Visibility(
                child: Loader(),
                visible: isLoading,
              ),
            ],
          ),
        ));
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
        AppString.events.tr.toUpperCase(),
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
    );
  }

  Future getEvents({
    String? cCode,
    num? page,
    String? text,
    String? city,
    String? eventTypeListFiltered,
  }) async {
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
        endpoint: GlobalKeys.GET_EVENTS,
        params: {
          "page": page.toString(),
          "search_by_global_search": text,
          "search_by_event_type":
              eventTypeListFiltered == "0" ? "" : eventTypeListFiltered,
          "search_by_city_name": city == AppString.all.tr ? "" : city,
          "search_by_country_code": cCode,
          "timezone": currentTimeZone
        },
        header: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        });
    setState(() {
      isLoading = false;
    });
    EventListResponseModel result = EventListResponseModel.fromJson(response);
    setState(() {
      if (cCode == null) countryData = Country.parse(result.data.userCountry);
      eventList = result.data.events;
      totalData = result.data.totalEvents;

      eventTypeList.clear();
      eventTypeList.add(Types(id: 0, name: AppString.all.tr));
      eventTypeList.addAll(result.data.types);
      if (selectedEventType == null) {
        selectedEventType = eventTypeList.first;
      } else {
        selectedEventType = eventTypeList.elementAt(eventTypeList.indexWhere(
            (element) => element.id == selectedEventType?.id ? true : false));
      }
    });
  }

  Future loadMoreEvents({
    String? cCode,
    num? page,
    String? text,
    String? city,
    String? eventTypeListFiltered,
  }) async {
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
        endpoint: GlobalKeys.GET_EVENTS,
        params: {
          "page": page.toString(),
          "search_by_global_search": text.toString(),
          "search_by_event_type":
              eventTypeListFiltered == "0" ? "" : eventTypeListFiltered,
          "search_by_city_name": city == AppString.all.tr ? "" : city,
          "search_by_country_code": cCode,
          "timezone": currentTimeZone
        },
        header: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        });
    setState(() {
      isLoading = false;
    });
    EventListResponseModel result = EventListResponseModel.fromJson(response);
    setState(() {
      if (cCode == null) countryData = Country.parse(result.data.userCountry);
      eventList.addAll(result.data.events);
      totalData = result.data.totalEvents;

      eventTypeList.clear();
      eventTypeList.add(Types(id: 0, name: AppString.all.tr));
      eventTypeList.addAll(result.data.types);
      if (selectedEventType == null) {
        selectedEventType = eventTypeList.first;
      } else {
        selectedEventType = eventTypeList.elementAt(eventTypeList.indexWhere(
            (element) => element.id == selectedEventType?.id ? true : false));
      }
    });
  }

  callBackChange(Cities cities) {
    setState(() {
      this.currentCity = cities;
      page = 1;
      getEvents(
          cCode: countryData.countryCode,
          city: currentCity.name,
          eventTypeListFiltered: selectedEventType?.id.toString(),
          page: page,
          text: _searchGlobalTextController.text);
    });
  }
}
