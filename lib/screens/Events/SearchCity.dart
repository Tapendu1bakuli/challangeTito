// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/CityList.dart';
import '../../util/AppString.dart';
import '../../util/TextStyles.dart';

class SearchCity extends StatefulWidget {
  List<Cities> allCityList = <Cities>[];
  late Cities currentCity = Cities(id: 0, name: AppString.all.tr);
  ValueChanged<Cities> callBackChange;

  SearchCity({
    required this.allCityList,
    required this.currentCity,
    required this.callBackChange,
  });

  @override
  _SearchCityState createState() => new _SearchCityState();
}

class _SearchCityState extends State<SearchCity> {
  TextEditingController controller = new TextEditingController();
  List<Cities> _searchResult = [];

  List<Cities> _cityDetails = [];

  @override
  void initState() {
    super.initState();
    _cityDetails = widget.allCityList;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        new Container(
          child: new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new ListTile(
              leading: new Icon(Icons.search),
              title: new TextField(
                controller: controller,
                decoration: new InputDecoration(
                    hintText: AppString.search.tr, border: InputBorder.none),
                onChanged: onSearchTextChanged,
              ),
              trailing: new IconButton(
                icon: new Icon(Icons.cancel),
                onPressed: () {
                  controller.clear();
                  onSearchTextChanged('');
                },
              ),
            ),
          ),
        ),
        new Expanded(
          child: _searchResult.length != 0 || controller.text.isNotEmpty
              ? new ListView.builder(
                  itemCount: _searchResult.length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          widget.currentCity = _searchResult[i];
                          widget.callBackChange(_searchResult[i]);
                        });
                      },
                      title: Text(_searchResult[i].name,
                          softWrap: true,
                          style: TextStyles.textStyleSemiBoldBack),
                    );
                  },
                )
              : new ListView.builder(
                  itemCount: _cityDetails.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          widget.currentCity = _cityDetails[index];
                          widget.callBackChange(_cityDetails[index]);
                        });
                      },
                      title: Text(_cityDetails[index].name,
                          softWrap: true,
                          style: TextStyles.textStyleSemiBoldBack),
                    );
                  },
                ),
        ),
      ],
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _cityDetails.forEach((city) {
      if (city.name.toLowerCase().contains(text.toLowerCase()))
        _searchResult.add(city);
    });

    setState(() {});
  }
}
