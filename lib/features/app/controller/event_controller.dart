import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contacts;
import 'package:huddle/features/app/model/event_model.dart';
import '../model/event.dart' as app;

class EventController {
  final EventModel _eventModel = EventModel();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createEvent({
    required String id,
    required String title,
    required String host,
    required String location,
    required DateTime dateTime,
    required List<contacts.Contact> attendees,
    required String groupId,
    required Map<String, String> invitationStatus,
    required String description,
    String? hostProfileUrl,
  }) async {
    final event = app.Event(
      id: id,
      title: title,
      host: host,
      location: location,
      dateTime: dateTime,
      attendees: attendees,
      groupId: groupId,
      invitationStatus: invitationStatus,
      description: description,
      hostProfileUrl: hostProfileUrl,
    );
    _eventModel.addEvent(event);
    // Persist event to Firestore under the group
    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('events')
        .doc(id)
        .set(event.toMap());
  }
}
