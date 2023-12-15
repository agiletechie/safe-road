import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:road_safety/data/data.dart';
import 'package:road_safety/data/models/report.dart';
import 'package:road_safety/provider/auth_notifier.dart';
import 'package:road_safety/provider/report_notifier.dart';
import 'package:road_safety/screens/issue.dart';
import 'package:road_safety/screens/map.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  void showInfo(BuildContext context, Report report) async {
    await showModalBottomSheet(
      backgroundColor: Colors.teal.shade100,
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: CachedNetworkImage(imageUrl: report.imageUrl),
            ),
            const SizedBox(height: 12),
            Text(
              report.title,
              style: const TextStyle(fontSize: 24),
            ),
            Text(report.description ?? ''),
            const SizedBox(height: 12),
            Align(
                alignment: Alignment.centerRight,
                child: Text(' Reported by:${report.reportedBy}')),
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReportNotifier>(
      create: (context) => ReportNotifier(data: Data())..getReports(),
      builder: (context, child) {
        return Scaffold(
          floatingActionButton: Consumer<ReportNotifier>(
            builder: (context, ReportNotifier notifier, child) {
              return FloatingActionButton.extended(
                extendedPadding: const EdgeInsets.symmetric(horizontal: 32),
                icon: notifier.mapView
                    ? const Icon(Icons.list)
                    : const Icon(Icons.map),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32)),
                onPressed: () {
                  notifier.toggleMapView();
                },
                label: notifier.mapView
                    ? const Text('ListView')
                    : const Text('MapView'),
              );
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                tileMode: TileMode.clamp,
                stops: const [0.1, 1],
                colors: [
                  Colors.teal.shade500,
                  Colors.teal.shade100,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 24,
                          child: Text(
                              Provider.of<AuthNotifier>(context, listen: false)
                                      .user
                                      ?.displayName?[0]
                                      .toUpperCase() ??
                                  ''),
                        ),
                        RichText(
                            text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold),
                                children: [
                              TextSpan(
                                  text: 'Road',
                                  style:
                                      TextStyle(color: Colors.lime.shade600)),
                              const TextSpan(
                                  text: 'Safe',
                                  style: TextStyle(color: Colors.amber)),
                            ])),
                        Row(
                          children: [
                            const Icon(
                              Icons.notifications_none,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            PopupMenuButton(
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    child: const Text('Logout'),
                                    onTap: () {
                                      Provider.of<AuthNotifier>(context,
                                              listen: false)
                                          .logout();
                                    },
                                  )
                                ];
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) {
                                return ChangeNotifierProvider.value(
                                    value: Provider.of<ReportNotifier>(context,
                                        listen: false),
                                    child: const IssuePage());
                              },
                            ));
                          },
                          child: const Text('Report an issue')),
                    ),
                    const Text(
                      'Recent issues',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Consumer<ReportNotifier>(
                      builder: (BuildContext context, ReportNotifier notifier,
                          child) {
                        if (notifier.mapView) {
                          return Expanded(
                              child: MapPage(
                                  reports: notifier.reports, info: showInfo));
                        }
                        return Expanded(
                          child: ListView.builder(
                            itemCount: notifier.reports.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  showInfo(context, notifier.reports[index]);
                                },
                                child:
                                    ReportCard(report: notifier.reports[index]),
                              );
                            },
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.report});

  final Report report;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(4),
      height: 100,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              placeholder: (context, url) {
                return Container();
              },
              width: 70,
              imageUrl: report.imageUrl,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                report.description ?? '',
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )
        ],
      ),
    );
  }
}
