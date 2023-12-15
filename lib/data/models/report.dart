import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  String reportedBy;
  String title;
  String? description;
  String imageUrl;
  GeoPoint location;

  Report({
    required this.reportedBy,
    required this.title,
    this.description,
    required this.imageUrl,
    required this.location,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    GeoPoint location = json['location'];
    return Report(
        reportedBy: json['reported_by'],
        title: json['title'],
        description: json['description'],
        imageUrl: json['imageUrl'],
        location: location);
  }

  Map<String, dynamic> toJson() {
    return {
      'reported_by': reportedBy,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'location': location
    };
  }
}
