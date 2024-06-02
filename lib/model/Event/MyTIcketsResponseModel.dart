class MyTicketsResponseModel {
  MyTicketsResponseModel({
    required this.responseCode,
    required this.status,
    required this.message,
    required this.data,
  });

  late final int responseCode;
  late final String status;
  late final String message;
  late final Data data;

  MyTicketsResponseModel.empty() {
    responseCode = 0;
    status = "";
    message = "";
    data = Data.empty();
  }

  MyTicketsResponseModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    status = json['status'];
    message = json['message'];
    data = Data.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['response_code'] = responseCode;
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class Data {
  Data({
    required this.tickets,
  });

  late final List<Tickets> tickets;

  Data.empty() {
    tickets = <Tickets>[];
  }

  Data.fromJson(Map<String, dynamic> json) {
    tickets =
        List.from(json['tickets']).map((e) => Tickets.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['tickets'] = tickets.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Tickets {
  Tickets({
    required this.city,
    required this.country,
    required this.venue,
    required this.eventCode,
    required this.ticketCode,
    required this.ticketStatus,
    required this.numberOfSets,
    required this.category,
    required this.amount,
    required this.expireOn,
    required this.qrCode,
    required this.artist,
    required this.purchaseDate,
    required this.eventTitle,
    required this.dateOfEvent,
  });

  late final String city;
  late final String country;
  late final String venue;
  late final String eventCode;
  late final String ticketCode;
  late final String ticketStatus;
  late final int numberOfSets;
  late final String category;
  late final num amount;
  late final String expireOn;
  late final String qrCode;
  late final String artist;
  late final String purchaseDate;
  late final String eventTitle;
  late final String dateOfEvent;
  late final String senderName;
  late final String receiverName;

  Tickets.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    country = json['country'];
    venue = json['venue'];
    eventCode = json['event_code'];
    ticketCode = json['ticket_code'];
    ticketStatus = json['ticket_status'];
    numberOfSets = json['number_of_sets'];
    category = json['category'];
    amount = json['amount'];
    expireOn = json['expire_on'];
    qrCode = json['qr_code'];
    artist = json['artist_name'];
    purchaseDate = json['purchase_date'] == null ? "" : json['purchase_date'];
    eventTitle = json['event_title'] == null ? "" : json['event_title'];
    dateOfEvent = json['date_of_event'] == null ? "" : json['date_of_event'];
    senderName = json['sender_name'] == null ? "" : json['sender_name'];
    receiverName = json['receiver_name'] == null ? "" : json['receiver_name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['city'] = city;
    _data['country'] = country;
    _data['venue'] = venue;
    _data['event_code'] = eventCode;
    _data['ticket_code'] = ticketCode;
    _data['ticket_status'] = ticketStatus;
    _data['number_of_sets'] = numberOfSets;
    _data['category'] = category;
    _data['amount'] = amount;
    _data['expire_on'] = expireOn;
    _data['qr_code'] = qrCode;
    _data['artist_name'] = artist;
    _data['purchase_date'] = purchaseDate;
    _data['event_title'] = eventTitle;
    _data['date_of_event'] = dateOfEvent;
    _data['sender_name'] = senderName;
    _data['receiver_name'] = receiverName;
    return _data;
  }
}
