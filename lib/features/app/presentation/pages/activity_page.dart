import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

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
        title: const Text('My Activity'),
        backgroundColor: Colors.tealAccent.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collectionGroup('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No activity found.'));
          }
          final events = snapshot.data!.docs.where((doc) {
            final map = doc.data() as Map<String, dynamic>;
            final invitationStatus = map['invitationStatus'] as Map<String, dynamic>?;
            return invitationStatus != null && invitationStatus.containsKey(userId);
          }).toList();
          events.sort((a, b) {
            final aMap = a.data() as Map<String, dynamic>;
            final bMap = b.data() as Map<String, dynamic>;
            final aDate = aMap['dateTime'] != null ? (aMap['dateTime'] as Timestamp).toDate() : DateTime.now();
            final bDate = bMap['dateTime'] != null ? (bMap['dateTime'] as Timestamp).toDate() : DateTime.now();
            return bDate.compareTo(aDate);
          });
          return ListView.separated(
            itemCount: events.length,
            separatorBuilder: (context, i) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final map = events[i].data() as Map<String, dynamic>;
              final title = map['title'] ?? 'Event';
              final date = map['dateTime'] != null ? (map['dateTime'] as Timestamp).toDate() : null;
              final status = (map['invitationStatus'] ?? {})[userId] ?? 'pending';
              IconData icon;
              Color color;
              String statusText;
              switch (status) {
                case 'accepted':
                  icon = Icons.check_circle;
                  color = Colors.green;
                  statusText = 'Accepted';
                  break;
                case 'declined':
                  icon = Icons.cancel;
                  color = Colors.red;
                  statusText = 'Declined';
                  break;
                case 'pending':
                  icon = Icons.hourglass_empty;
                  color = Colors.orange;
                  statusText = 'Pending';
                  break;
                default:
                  icon = Icons.info_outline;
                  color = Colors.grey;
                  statusText = status.toString();
              }
              return ListTile(
                leading: Icon(icon, color: color),
                title: Text(title),
                subtitle: date != null
                    ? Text(DateFormat('yyyy-MM-dd – kk:mm').format(date))
                    : null,
                trailing: Text(statusText, style: TextStyle(color: color)),
              );
            },
          );
        },
      ),
    );
  }
}
