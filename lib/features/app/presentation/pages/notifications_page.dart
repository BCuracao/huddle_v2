import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:huddle/features/app/model/event.dart';
import 'package:huddle/features/app/presentation/pages/event_details_page.dart';
import 'package:huddle/features/app/presentation/widgets/global_bottom_app_bar_widget.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not signed in.')),
      );
    }
    final userId = user.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, notificationSnapshot) {
          if (notificationSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Get event invitations
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collectionGroup('events')
                .where('invitationStatus.$userId', isNotEqualTo: null)
                .snapshots(),
            builder: (context, eventSnapshot) {
              if (eventSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              List<Widget> notificationItems = [];
              
              // Add cancellation notifications
              if (notificationSnapshot.hasData) {
                for (var doc in notificationSnapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['type'] == 'event_cancelled') {
                    notificationItems.add(
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: Colors.red.shade50,
                        child: ListTile(
                          leading: const Icon(Icons.cancel, color: Colors.red),
                          title: Text(
                            'Event Cancelled: ${data['eventTitle']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Host: ${data['eventHost']}'),
                              Text('Reason: ${data['cancellationReason']}'),
                              if (data['timestamp'] != null)
                                Text(
                                  'Cancelled: ${(data['timestamp'] as Timestamp).toDate().toString().split('.')[0]}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () {
                              // Mark notification as read/delete it
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .collection('notifications')
                                  .doc(doc.id)
                                  .delete();
                            },
                          ),
                        ),
                      ),
                    );
                  }
                }
              }
              
              // Add event invitations
              if (eventSnapshot.hasData && eventSnapshot.data!.docs.isNotEmpty) {
                final events = eventSnapshot.data!.docs
                    .map((doc) => Event.fromMap(doc.data() as Map<String, dynamic>, []))
                    .toList();
                
                for (var event in events) {
                  final status = event.invitationStatus[userId] ?? 'pending';
                  String statusText;
                  Color statusColor;
                  IconData statusIcon;
                  
                  switch (status) {
                    case 'accepted':
                      statusText = 'You accepted the invitation';
                      statusColor = Colors.green;
                      statusIcon = Icons.check_circle;
                      break;
                    case 'declined':
                      statusText = 'You declined the invitation';
                      statusColor = Colors.red;
                      statusIcon = Icons.cancel;
                      break;
                    case 'pending':
                    default:
                      statusText = 'You are invited!';
                      statusColor = Colors.orange;
                      statusIcon = Icons.mail;
                  }
                  
                  notificationItems.add(
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: Icon(statusIcon, color: statusColor),
                        title: Text(event.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(statusText, style: TextStyle(color: statusColor)),
                            Text('Host: ${event.host}'),
                            Text(
                              'Date: ${event.dateTime.year}-${event.dateTime.month.toString().padLeft(2, '0')}-${event.dateTime.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EventDetailsPage(event: event),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              }
              
              if (notificationItems.isEmpty) {
                return const Center(child: Text('No notifications yet.'));
              }
              
              return ListView(
                children: notificationItems,
              );
            },
          );
        },
      ),
    );
  }
}
