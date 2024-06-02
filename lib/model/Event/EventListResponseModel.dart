class EventListResponseModel {
  EventListResponseModel({
    required this.responseCode,
    required this.status,
    required this.message,
    required this.data,
  });

  late final int responseCode;
  late final String status;
  late final String message;
  late final Data data;

  EventListResponseModel.fromJson(Map<String, dynamic> json) {
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
    required this.userCountry,
    required this.types,
    required this.totalEvents,
    required this.events,
  });

  late final String userCountry;
  late final List<Types> types;
  late final int totalEvents;
  late final List<Events> events;

  Data.fromJson(Map<String, dynamic> json) {
    userCountry = json['user_country'];
    types = List.from(json['types']).map((e) => Types.fromJson(e)).toList();
    totalEvents = json['total_events'];
    events = List.from(json['events']).map((e) => Events.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['user_country'] = userCountry;
    _data['types'] = types.map((e) => e.toJson()).toList();
    _data['total_events'] = totalEvents;
    _data['events'] = events.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Types {
  Types({
    required this.id,
    required this.name,
  });

  late final int id;
  late final String name;

  Types.fromJson(Map<String, dynamic> json) {
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

class Events {
  Events({
    required this.eventManagementId,
    required this.eventCode,
    required this.artistName,
    required this.venue,
    required this.title,
    required this.thumbnail,
    required this.ticketBookingStart,
    required this.ticketBookingEnd,
    required this.dateOfEvent,
    required this.category,
    required this.paymentUrl,
    required this.paymentUrlStatus,
    this.totalSeatAvailable = 0,
  });

  late final int eventManagementId;
  late final String eventCode;
  late final bool paymentUrlStatus;
  late final String paymentUrl;
  late final String artistName;
  late final String venue;
  late final String title;
  late final String thumbnail;
  late final String ticketBookingStart;
  late final String ticketBookingEnd;
  late final String dateOfEvent;
  late num totalSeatAvailable;
  late final List<Category> category;

  Events.fromJson(Map<String, dynamic> json) {
    eventManagementId = json['event_management_id'];
    eventCode = json['event_code'];
    artistName = json['artist_name'];
    venue = json['venue'];
    paymentUrlStatus =
        json['payment_url_status'] != null || json['payment_url_status'] != ""
            ? json['payment_url_status'].toString().toLowerCase() == "enable"
                ? true
                : false
            : false;
    paymentUrl = json['payment_url'];
    title = json['title'];
    thumbnail = json['thumbnail'];
    ticketBookingStart = json['ticket_booking_start'] == null
        ? "0000-00-00"
        : json['ticket_booking_start'];
    ticketBookingEnd = json['ticket_booking_end'] == null
        ? "0000-00-00"
        : json['ticket_booking_end'];
    dateOfEvent = json['date_of_event'];
    totalSeatAvailable = 0;
    category = List.from(json['category']).map((e) {
      totalSeatAvailable = totalSeatAvailable + e["available_seat_for_booking"];
      return Category.fromJson(e);
    }).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['event_management_id'] = eventManagementId;
    _data['event_code'] = eventCode;
    _data['artist_name'] = artistName;
    _data['venue'] = venue;
    _data['title'] = title;
    _data['thumbnail'] = thumbnail;
    _data['ticket_booking_start'] = ticketBookingStart;
    _data['ticket_booking_end'] = ticketBookingEnd;
    _data['date_of_event'] = dateOfEvent;
    _data['category'] = category.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Category {
  Category({
    required this.seatCategoryId,
    required this.name,
    required this.perSeatTos,
    required this.seatBooked,
    required this.totalSeat,
    required this.availableSeatForBooking,
  });

  late final int seatCategoryId;
  late final String name;
  late final int perSeatTos;
  late final String seatBooked;
  late final String totalSeat;
  late final int availableSeatForBooking;

  Category.fromJson(Map<String, dynamic> json) {
    seatCategoryId = json['seat_category_id'];
    name = json['name'];
    perSeatTos = json['per_seat_tos'];
    seatBooked = json['seat_booked'];
    totalSeat = json['total_seat'];
    availableSeatForBooking = json['available_seat_for_booking'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['seat_category_id'] = seatCategoryId;
    _data['name'] = name;
    _data['per_seat_tos'] = perSeatTos;
    _data['seat_booked'] = seatBooked;
    _data['total_seat'] = totalSeat;
    _data['available_seat_for_booking'] = availableSeatForBooking;
    return _data;
  }
}
