class PaymentAccountListModel {
  PaymentAccountListModel({
    this.status = "",
    // required this.paymentTypes,
    this.message = "",
    this.url = "",
  });

  late final String status;

  // late final List<PaymentTypes> paymentTypes;
  late final String message;
  late final String url;

  PaymentAccountListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    /*  paymentTypes = List.from(json['paymentTypes'])
        .map((e) => PaymentTypes.fromJson(e))
        .toList(); */
    message = json['msg'];
    url = json['url'] == null ? "" : json['url'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    // _data['paymentTypes'] = paymentTypes.map((e) => e.toJson()).toList();
    _data['msg'] = message;
    _data['url'] = url;

    return _data;
  }
}

class PaymentTypes {
  PaymentTypes(
      {required this.id,
      required this.paymentType,
      required this.type,
      required this.logoPath,
      this.isSelected});

  late final int id;
  late final String paymentType;
  late final String type;
  late final String logoPath;
  bool? isSelected;

  PaymentTypes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    paymentType = json['payment_type'];
    type = json['type'];
    logoPath = json['logo_path'];
    isSelected = false;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['payment_type'] = paymentType;
    _data['type'] = type;
    _data['logo_path'] = logoPath;
    return _data;
  }
}
