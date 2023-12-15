import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:road_safety/data/models/report.dart';
import 'package:road_safety/provider/report_notifier.dart';

class IssuePage extends StatefulWidget {
  const IssuePage({super.key});

  @override
  State<IssuePage> createState() => _IssuePageState();
}

class _IssuePageState extends State<IssuePage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? image;
  final Location _location = Location();
  LocationData? _locationData;
  bool? _serviceEnabled;
  PermissionStatus? _permissionStatus;

  void getPermission() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!(_serviceEnabled ?? true)) {
      _serviceEnabled = await _location.requestService();
      if (!(_serviceEnabled ?? false)) {
        return;
      }
    }

    _permissionStatus = await _location.hasPermission();
    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await _location.requestPermission();
      if (_permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

    try {
      _locationData = await _location.getLocation();
    } catch (e) {
      _locationData = null;
    }
  }

  @override
  void initState() {
    _titleController = TextEditingController();
    _descController = TextEditingController();
    getPermission();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add an issue'),
        backgroundColor: Colors.orange.shade100,
      ),
      backgroundColor: Colors.orange.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        image = await _imagePicker.pickImage(
                            source: ImageSource.camera, imageQuality: 50);
                        setState(() {});
                      } catch (e) {
                        image = null;
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Failed to take photo. Try again!')));
                        }
                      }
                    },
                    child: Card(
                      clipBehavior: Clip.hardEdge,
                      elevation: 2,
                      surfaceTintColor: Colors.orange,
                      child: image != null
                          ? Image.file(
                              File(image!.path),
                              fit: BoxFit.cover,
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_outlined, size: 44),
                                Text('Tap here to add an image'),
                              ],
                            ),
                    ),
                  ),
                ),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(label: Text('Title')),
                ),
                TextField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(label: Text('Description')),
                ),
                const SizedBox(
                  height: 128,
                ),
                Consumer<ReportNotifier>(
                  builder: (BuildContext context, ReportNotifier value, child) {
                    if (!value.isLoading && value.addedDoc) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added!')));
                        value.setAddedDocValue(false);
                        value.getReports();
                        Navigator.of(context).pop();
                      });
                    }
                    return value.isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Reporting'),
                              SizedBox(width: 8),
                              CircularProgressIndicator(),
                            ],
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              if (image != null &&
                                  _titleController.text.isNotEmpty) {
                                value.addReport(
                                    image!,
                                    Report(
                                        reportedBy: '',
                                        title: _titleController.text,
                                        description: _descController.text,
                                        imageUrl: '',
                                        location: GeoPoint(
                                            _locationData?.latitude ?? 12.9106,
                                            _locationData?.longitude ??
                                                77.1606)));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Fill all details!')));
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32.0),
                              child: Text(
                                'Report',
                              ),
                            ));
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
