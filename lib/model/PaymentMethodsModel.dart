class PaymentMethodsModel {
  PaymentMethodsModel({
    required this.status,
    required this.msg,
    required this.data,
  });

  late final String status;
  late final String msg;
  late final List<Data> data;

  PaymentMethodsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    data = List.from(json['data']).map((e) => Data.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['msg'] = msg;
    _data['data'] = data.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Data {
  Data({
    required this.method,
    required this.url,
    required this.avlPaymentMethod,
  });

  late final String method;
  late final String url;
  late final String avlPaymentMethod;

  Data.fromJson(Map<String, dynamic> json) {
    method = json['method'];
    url = json['url'];
    avlPaymentMethod = json['AvlPaymentMethod'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['method'] = method;
    _data['url'] = url;
    _data['AvlPaymentMethod'] = avlPaymentMethod;
    return _data;
  }
}
