import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:road_safety/data/data.dart';
import 'package:road_safety/provider/auth_notifier.dart';
import 'package:road_safety/provider/report_notifier.dart';
import 'package:road_safety/screens/issue.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReportNotifier>(
      create: (context) => ReportNotifier(data: Data())..getReports(),
      builder: (context, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              // gradient: LinearGradient(
              //   begin: Alignment.topLeft,
              //   tileMode: TileMode.clamp,
              //   stops: [0.1, 1],
              //   colors: [
              //     Colors.teal.shade500,
              //     Colors.teal.shade100,
              //     // Colors.teal.shade100,
              //   ],
              // ),
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
                          child: Text('S'),
                          backgroundColor: Colors.white,
                          radius: 24,
                        ),
                        RichText(
                            text: TextSpan(
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold),
                                children: [
                              TextSpan(
                                  text: 'Road',
                                  style:
                                      TextStyle(color: Colors.lime.shade600)),
                              TextSpan(
                                  text: 'Safe',
                                  style: TextStyle(color: Colors.amber)),
                            ])),
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 28,
                              color: Colors.white,
                            ),
                            SizedBox(width: 12),
                            // IconButton(
                            //     onPressed: () {}, icon: Icon(Icons.more_vert))
                            PopupMenuButton(
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    child: Text('Logout'),
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
                    SizedBox(
                      height: 32,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) {
                                return ChangeNotifierProvider.value(
                                    value: Provider.of<ReportNotifier>(context,
                                        listen: false),
                                    child: IssuePage());
                              },
                            ));
                          },
                          child: Text('Report an issue')),
                    ),
                    Text('Recent issues'),
                    Consumer<ReportNotifier>(
                      builder:
                          (BuildContext context, ReportNotifier value, child) {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: value.reports.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                // tileColor: Colors.red,
                                leading: CachedNetworkImage(
                                    imageUrl: value.reports[index].imageUrl,
                                    width: 42),
                                title: Text(value.reports[index].title),
                                subtitle: Text(
                                    value.reports[index].description ?? ''),
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
