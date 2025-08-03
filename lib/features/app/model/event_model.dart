import 'event.dart';

class EventModel {
  List<Event> events = [];

  List<Event> getEvents() {
    return events;
  }

  void addEvent(Event event) {
    events.add(event);
  }

  void deleteEvent(Event event) {
    for (int i = 0; i < events.length; i++) {
      if (event.id == events[i].id) {
        events.removeAt(i);
      }
    }
  }
}
