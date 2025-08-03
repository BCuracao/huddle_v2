import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:huddle/features/app/model/event.dart' as app_event;
import 'package:huddle/features/app/presentation/widgets/global_bottom_app_bar_widget.dart';
import 'package:intl/intl.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:huddle/features/app/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _userId;
  String? _userDisplayName;
  List<String> _lastQueriedGroupIds = [];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _userId = user?.uid;
    _userDisplayName = user?.displayName ?? user?.email;
  }

  Stream<List<app_event.Event>> _eventsStream(
      {void Function(List<String>)? onGroupIds}) async* {
    if (_userId == null) {
      yield [];
      return;
    }
    // Get user's groups
    final userGroupsSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('groups')
        .get();
    final groupIds = userGroupsSnap.docs.map((d) => d.id).toList();
    if (onGroupIds != null) onGroupIds(groupIds);
    if (groupIds.isEmpty) {
      yield [];
      return;
    }
    yield* FirebaseFirestore.instance
        .collectionGroup('events')
        .where('groupId', whereIn: groupIds)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => app_event.Event.fromMap(doc.data(), []))
            .where((event) =>
                event.host == _userDisplayName ||
                event.invitationStatus.containsKey(_userId))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
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
      body: StreamBuilder<List<app_event.Event>>(
        stream: _eventsStream(onGroupIds: (ids) => _lastQueriedGroupIds = ids),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading events: \n'
                  'Group IDs: \n${_lastQueriedGroupIds.join(", ")}\n'
                  'Error: \n${snapshot.error}'),
            );
          }
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = snapshot.data!;
          if (events.isEmpty) {
            return Center(
              child: Text(
                  'No events found.\nGroup IDs: ${_lastQueriedGroupIds.join(", ")}'),
            );
          }
          return Stack(
            children: [
              // Gradient Header
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
                  height: 500,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 20.0),
                      child: Stack(
                        children: [
                          // Invitations title and icon moved up
                          const Positioned(
                            top: 10,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Invitations',
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
                          // Profile button remains lower right
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, right: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const ProfilePage(),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(Icons.person,
                                      color: Colors.white, size: 28),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Main Content
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 160.0, left: 16, right: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: CardSwiper(
                          padding: EdgeInsets.zero,
                          cardsCount: events.length,
                          numberOfCardsDisplayed: 1,
                          cardBuilder: (context, index, _, __) {
                            final event = events[index];
                            final status = event.host == _userDisplayName
                                ? 'host'
                                : event.invitationStatus[_userId] ?? 'pending';
                            Color iconColor;
                            IconData icon;
                            String statusText;
                            switch (status) {
                              case 'accepted':
                                icon = Icons.check_circle;
                                iconColor = Colors.green;
                                statusText = 'You are attending';
                                break;
                              case 'declined':
                                icon = Icons.cancel;
                                iconColor = Colors.red;
                                statusText = 'You declined';
                                break;
                              case 'host':
                                icon = Icons.star;
                                iconColor = Colors.blueAccent;
                                statusText = 'You are the host';
                                break;
                              default:
                                icon = Icons.hourglass_empty;
                                iconColor = Colors.orange;
                                statusText = 'Undecided';
                            }
                            final acceptedUsers = event.invitationStatus.entries
                                .where((e) => e.value == 'accepted')
                                .map((e) => e.key)
                                .toList();
                            final acceptedCount = event.invitationStatus.values
                                .where((v) => v == 'accepted')
                                .length;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Material(
                                  elevation: 10,
                                  borderRadius: BorderRadius.circular(28),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Placeholder for user/event image
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(28),
                                            topRight: Radius.circular(28),
                                          ),
                                          child: Container(
                                            height: 220,
                                            width: double.infinity,
                                            color: Colors.grey[200],
                                            child:
                                                event.hostProfileUrl != null &&
                                                        event.hostProfileUrl!
                                                            .isNotEmpty
                                                    ? Image.network(
                                                        event.hostProfileUrl!,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : const Icon(Icons.person,
                                                        size: 90,
                                                        color: Colors.grey),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      event.title,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 24,
                                                        color: Colors.teal[900],
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Icon(icon,
                                                      color: iconColor,
                                                      size: 24),
                                                  // Cancel button for host
                                                  if (event.host ==
                                                      _userDisplayName) ...[
                                                    const SizedBox(width: 8),
                                                    GestureDetector(
                                                      onTap: () =>
                                                          _showCancelEventDialog(
                                                              event),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(6),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.red
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: const Icon(
                                                          Icons.close,
                                                          color: Colors.red,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${event.host}, ${DateFormat('yyyy-MM-dd – kk:mm').format(event.dateTime)}',
                                                style: TextStyle(
                                                  color: Colors.teal[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              if (event.description.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Text(
                                                    event.description,
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black87),
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.people,
                                                        color: Colors.green,
                                                        size: 20),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Accepted: $acceptedCount',
                                                      style: const TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (acceptedUsers.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Text(
                                                    'Attending: ${acceptedUsers.join(", ")}',
                                                    style: const TextStyle(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              const SizedBox(height: 8),
                                              Text(
                                                statusText,
                                                style: TextStyle(
                                                  color: iconColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Swipe hint below event card
                                const Padding(
                                  padding: EdgeInsets.only(top: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.arrow_back,
                                          color: Colors.green, size: 20),
                                      SizedBox(width: 4),
                                      Text('Accept',
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 13)),
                                      SizedBox(width: 14),
                                      Icon(Icons.arrow_forward,
                                          color: Colors.redAccent, size: 20),
                                      SizedBox(width: 4),
                                      Text('Decline',
                                          style: TextStyle(
                                              color: Colors.redAccent,
                                              fontSize: 13)),
                                      SizedBox(width: 14),
                                      Icon(Icons.arrow_upward,
                                          color: Colors.orange, size: 20),
                                      Icon(Icons.arrow_downward,
                                          color: Colors.orange, size: 20),
                                      SizedBox(width: 4),
                                      Text('Undecided',
                                          style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: 13)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),
                              ],
                            );
                          },
                          onSwipe:
                              (previousIndex, currentIndex, direction) async {
                            final event = events[previousIndex];
                            if (event.host == _userDisplayName) {
                              return true;
                            }
                            if (direction == CardSwiperDirection.left) {
                              _respondToEvent(event, 'declined');
                            } else if (direction == CardSwiperDirection.right) {
                              _respondToEvent(event, 'accepted');
                            } else if (direction == CardSwiperDirection.top ||
                                direction == CardSwiperDirection.bottom) {
                              _respondToEvent(event, 'pending');
                            }
                            return true;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return RawMaterialButton(
      onPressed: onPressed,
      elevation: 4.0,
      fillColor: color.withOpacity(0.12),
      shape: const CircleBorder(),
      constraints: const BoxConstraints.tightFor(width: 56, height: 56),
      child: Icon(icon, color: color, size: 28),
    );
  }

  Future<void> _respondToEvent(app_event.Event event, String response) async {
    if (_userId == null) return;
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(event.groupId)
        .collection('events')
        .doc(event.id)
        .update({'invitationStatus.${_userId}': response});
  }

  void _showCancelEventDialog(app_event.Event event) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to cancel "${event.title}"?'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Let your friends know why...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Keep Event'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelEvent(event, reasonController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel Event'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelEvent(app_event.Event event, String reason) async {
    if (_userId == null || event.host != _userDisplayName) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Create cancellation notification for all invitees
      final batch = FirebaseFirestore.instance.batch();

      // Add cancellation notification to each invitee's notifications
      for (String inviteeId in event.invitationStatus.keys) {
        final notificationRef = FirebaseFirestore.instance
            .collection('users')
            .doc(inviteeId)
            .collection('notifications')
            .doc();

        batch.set(notificationRef, {
          'type': 'event_cancelled',
          'eventTitle': event.title,
          'eventHost': event.host,
          'eventDate': event.dateTime,
          'cancellationReason':
              reason.isNotEmpty ? reason : 'No reason provided',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
      }

      // Delete the event document
      final eventRef = FirebaseFirestore.instance
          .collection('groups')
          .doc(event.groupId)
          .collection('events')
          .doc(event.id);

      batch.delete(eventRef);

      // Commit all changes
      await batch.commit();

      // Hide loading indicator
      if (mounted) {
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Event "${event.title}" has been cancelled and all invitees have been notified.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Hide loading indicator
      if (mounted) {
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
