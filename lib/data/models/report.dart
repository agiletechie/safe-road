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
    final DocumentReference ref = json['reported_by'];
    GeoPoint location = json['location'];
    return Report(
        reportedBy: ref.id,
        title: json['title'],
        description: json['description'],
        imageUrl: json['imageUrl'],
        location: location);
  }

  Map<String, dynamic> toJson() {
    return {
      'reported_by': 'ref',
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'location': location
    };
  }
}
