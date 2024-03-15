class NotificationModel {
  String title;
  String description;
  DateTime dateTime;
  NotificationModel(
        this.title,
        this.description,
        this.dateTime
      );
}

List<NotificationModel> notifications = [
   NotificationModel("New Design","A new has been uploaded",DateTime.now()),
   NotificationModel("Hot Design", "The hottest dresses.",DateTime.now()),
];