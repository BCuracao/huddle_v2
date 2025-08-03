import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:huddle/features/app/model/event.dart';
import 'package:huddle/features/app/presentation/pages/event_details_page.dart';
import 'package:huddle/features/app/presentation/widgets/global_bottom_app_bar_widget.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Map<DateTime, List<Event>> _eventsByDay;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _eventsByDay = {};
  }

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
      body: Column(
        children: [
          // Gradient Header with Calendar inside
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.0),
                ],
                stops: const [1, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.tealAccent[400]!,
                    const Color.fromARGB(255, 122, 255, 222),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SafeArea(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Calendar',
                          style: TextStyle(
                            shadows: [
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 8.0,
                                color: Colors.black38,
                              ),
                              Shadow(
                                offset: Offset(0, 1.5),
                                blurRadius: 0.5,
                                color: Colors.black12,
                              ),
                            ],
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.0,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Calendar widget inside header
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 8.0, right: 8.0, bottom: 12.0),
                      child: TableCalendar<Event>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2100, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        eventLoader: (day) =>
                            _eventsByDay[DateTime(day.year, day.month, day.day)] ??
                            [],
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        calendarStyle: const CalendarStyle(
                          markerDecoration:
                              BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Event info preview (below header+calendar)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('events')
                  .where('invitationStatus.$userId', isNotEqualTo: null)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('No events found.'));
                }
                final docs = snapshot.data!.docs;
                final events = docs
                    .map((doc) =>
                        Event.fromMap(doc.data() as Map<String, dynamic>, []))
                    .toList();
                _eventsByDay = {};
                for (final event in events) {
                  final day = DateTime(event.dateTime.year,
                      event.dateTime.month, event.dateTime.day);
                  _eventsByDay.putIfAbsent(day, () => []).add(event);
                }
                final todayEvents = _selectedDay == null
                    ? []
                    : _eventsByDay[DateTime(_selectedDay!.year,
                            _selectedDay!.month, _selectedDay!.day)] ??
                        [];
                if (_selectedDay == null || todayEvents.isEmpty) {
                  return const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
                    child: Text('No events for this day.',
                        style: TextStyle(color: Colors.black87, fontSize: 16)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 6.0),
                  itemCount: todayEvents.length,
                  itemBuilder: (context, idx) {
                    final event = todayEvents[idx];
                    return Card(
                      color: Colors.teal.withOpacity(0.08),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    event.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontSize: 17),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Text(event.location,
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 14)),
                            if (event.description != null &&
                                event.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  event.description.length > 100
                                      ? event.description.substring(0, 100) +
                                          '...'
                                      : event.description,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
