import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:huddle/features/app/model/event.dart';
import 'package:huddle/features/app/presentation/widgets/global_bottom_app_bar_widget.dart';

class EventDetailsPage extends StatelessWidget {
  final Event event;
  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      bottomNavigationBar: const GlobalBottomAppBarWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/events");
        },
        backgroundColor: Colors.transparent,
        shape: const CircleBorder(),
        elevation: 12,
        child: Image.asset(
          "assets/images/icons/icon_app_icon.png",
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('yyyy-MM-dd – kk:mm').format(event.dateTime)}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('Host: ${event.host}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            if (event.description.isNotEmpty) ...[
              const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(event.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
            ],
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
