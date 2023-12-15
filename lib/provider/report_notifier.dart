import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:road_safety/data/data.dart';
import 'package:road_safety/data/models/report.dart';

class ReportNotifier with ChangeNotifier {
  ReportNotifier({required data}) : _data = data;

  final Data _data;
  List<Report> _reports = [];
  bool _hasException = false;
  String? _imageLink;
  bool _isLoading = false;
  bool _addedDoc = false;
  bool _mapView = false;

  List<Report> get reports => _reports;
  bool get hasException => _hasException;
  String? get link => _imageLink;
  bool get isLoading => _isLoading;
  bool get addedDoc => _addedDoc;
  bool get mapView => _mapView;

  void getReports() async {
    _hasException = false;
    try {
      _reports = await _data.getReports();
    } catch (e) {
      _hasException = true;
    }
    notifyListeners();
  }

  void addReport(XFile image, Report report) async {
    _hasException = false;
    _addedDoc = false;
    try {
      _isLoading = true;
      notifyListeners();
      await _data.writeReport(image, report);
      _addedDoc = true;
    } catch (e) {
      _hasException = true;
    }
    _isLoading = false;

    notifyListeners();
  }

  void toggleMapView() {
    _mapView = !_mapView;
    notifyListeners();
  }

  void setAddedDocValue(bool docValue) {
    _addedDoc = docValue;
  }
}
