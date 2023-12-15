import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:road_safety/data/models/report.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key, required this.reports, required this.info});

  final List<Report> reports;
  final Function(BuildContext, Report) info;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: FlutterMap(
          options: const MapOptions(
              initialZoom: 12,
              maxZoom: 17,
              minZoom: 7,
              interactionOptions:
                  InteractionOptions(flags: ~InteractiveFlag.rotate),
              initialCenter: LatLng(12.9716, 77.5946)),
          children: [
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(24)),
              child: TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
            ),
            MarkerLayer(markers: [
              ...reports.map(
                (report) {
                  return Marker(
                      point: LatLng(
                          report.location.latitude, report.location.longitude),
                      child: GestureDetector(
                        onTap: () {
                          info(context, report);
                        },
                        child: CustomMarker(
                          report: report,
                        ),
                      ));
                },
              )
            ]),
          ]),
    );
  }
}

class CustomMarker extends StatelessWidget {
  const CustomMarker({super.key, required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.location_pin,
      shadows: [
        BoxShadow(
          color: Colors.deepPurple,
          spreadRadius: 10,
          blurRadius: 10,
        ),
      ],
      color: Colors.deepPurple,
      size: 42,
    );
  }
}
