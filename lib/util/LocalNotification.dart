import 'package:rxdart/rxdart.dart';

class LocalNotification {
  final String type;

  LocalNotification(this.type);
}

class NotificationsBloc {
  NotificationsBloc._internal();

  static final NotificationsBloc instance = NotificationsBloc._internal();

  final BehaviorSubject<LocalNotification> _notificationsStreamController =
      BehaviorSubject<LocalNotification>();

  Stream<LocalNotification> get notificationsStream {
    return _notificationsStreamController;
  }

  void newNotification(LocalNotification notification) {
    _notificationsStreamController.sink.add(notification);
  }

  void dispose() {
    _notificationsStreamController.close();
  }
}
