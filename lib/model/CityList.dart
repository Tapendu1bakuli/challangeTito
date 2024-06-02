class CityList {
  CityList({
    required this.cities,
  });

  late final List<Cities> cities;

  CityList.fromJson(Map<String, dynamic> json) {
    cities = List.from(json['cities']).map((e) => Cities.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['cities'] = cities.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Cities {
  Cities({
    required this.id,
    required this.name,
  });

  late final int id;
  late final String name;

  Cities.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    return _data;
  }
}
