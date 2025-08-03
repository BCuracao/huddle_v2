import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class Event {
  String id;
  String title;
  String host;
  String location;
  DateTime dateTime;
  List<Contact> attendees;
  String groupId;
  Map<String, String> invitationStatus; // userId -> 'pending'|'accepted'|'declined'
  final String description;
  final String? hostProfileUrl;

  Event({
    required this.id,
    required this.title,
    required this.host,
    required this.location,
    required this.dateTime,
    required this.attendees,
    required this.groupId,
    required this.invitationStatus,
    required this.description,
    this.hostProfileUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'host': host,
      'location': location,
      'dateTime': Timestamp.fromDate(dateTime),
      'attendees': attendees.map((c) => c.id).toList(),
      'groupId': groupId,
      'invitationStatus': invitationStatus,
      'description': description,
      'hostProfileUrl': hostProfileUrl,
    };
  }

  static Event fromMap(Map<String, dynamic> map, List<Contact> contacts) {
    return Event(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      host: map['host'] ?? '',
      location: map['location'] ?? '',
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      attendees: contacts,
      groupId: map['groupId'] ?? '',
      invitationStatus: Map<String, String>.from(map['invitationStatus'] ?? {}),
      description: map['description'] ?? '',
      hostProfileUrl: map['hostProfileUrl'] as String?,
    );
  }
}
