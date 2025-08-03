import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:huddle/features/app/model/event.dart';
import 'event_edit_page.dart';
import 'package:huddle/features/app/presentation/widgets/global_bottom_app_bar_widget.dart';

class EditEventsPage extends StatefulWidget {
  const EditEventsPage({super.key});

  @override
  State<EditEventsPage> createState() => _EditEventsPageState();
}

class _EditEventsPageState extends State<EditEventsPage> {
  List<Event> _hostedEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHostedEvents();
  }

  Future<void> _fetchHostedEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      final eventsSnapshot = await FirebaseFirestore.instance
          .collectionGroup('events')
          .where('host', isEqualTo: user.displayName ?? user.email)
          .get();
      setState(() {
        _hostedEvents = eventsSnapshot.docs
            .map((doc) => Event.fromMap(doc.data(), []))
            .toList();
        _isLoading = false;
      });
    } catch (e, st) {
      debugPrint('Error fetching hosted events: $e\n$st');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load events: $e')),
      );
    }
  }

  void _openEditEvent(Event event) async {
    final updated = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventEditPage(event: event),
      ),
    );
    if (updated == true) {
      _fetchHostedEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const GlobalBottomAppBarWidget(),
      body: Stack(
        children: [
          // Background gradient header
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
              height: 200,
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
              child: SafeArea(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Events',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content area
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 160.0, left: 16, right: 16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _hostedEvents.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/icons/icon_app_icon.png',
                                      width: 80,
                                      height: 80,
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'You are not hosting any events.',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        color: Colors.teal.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                child: ListView.separated(
                                  itemCount: _hostedEvents.length,
                                  separatorBuilder: (context, idx) =>
                                      const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final event = _hostedEvents[index];
                                    return Material(
                                      elevation: 2,
                                      borderRadius: BorderRadius.circular(18),
                                      color: Colors.tealAccent.shade100
                                          .withOpacity(0.15),
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              Colors.tealAccent.shade700,
                                          child: const Icon(Icons.event,
                                              color: Colors.white),
                                        ),
                                        title: Text(
                                          event.title,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            color: Colors.teal.shade900,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event.location,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: Colors.teal.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Date: ${event.dateTime.year}-${event.dateTime.month.toString().padLeft(2, '0')}-${event.dateTime.day.toString().padLeft(2, '0')}',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                              Icons.edit_note_rounded,
                                              color: Colors.teal,
                                              size: 32),
                                          tooltip: 'Edit Event',
                                          onPressed: () =>
                                              _openEditEvent(event),
                                        ),
                                        onTap: () => _openEditEvent(event),
                                      ),
                                    );
                                  },
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
