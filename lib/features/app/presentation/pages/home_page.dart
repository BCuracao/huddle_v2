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
      backgroundColor: const Color(0xFFF8FAFC), // Modern clean background
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return Center(
              child: Text(
                  'No events found.\nGroup IDs: ${_lastQueriedGroupIds.join(", ")}'),
            );
          }

          return CustomScrollView(
            slivers: [
              // Modern Compact Header
              SliverAppBar(
                expandedHeight: 220,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1E3A8A), // Deep Blue - Trust & Reliability
                          Color(0xFF8B5CF6), // Soft Purple - Social & Creative
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Your Events',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ProfilePage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage your invitations and events',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Quick Stats Row
                            Row(
                              children: [
                                _buildQuickStat(
                                  'Total',
                                  '${events.length}',
                                  Icons.event,
                                ),
                                const SizedBox(width: 16),
                                _buildQuickStat(
                                  'Attending',
                                  '${events.where((e) => e.invitationStatus[_userId] == 'accepted').length}',
                                  Icons.check_circle,
                                ),
                                const SizedBox(width: 16),
                                _buildQuickStat(
                                  'Hosting',
                                  '${events.where((e) => e.host == _userDisplayName).length}',
                                  Icons.star,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Tinder-Style Event Swiper
              SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CardSwiper(
                    cardsCount: events.length,
                    numberOfCardsDisplayed: 3,
                    backCardOffset: const Offset(30, 0),
                    padding: EdgeInsets.zero,
                    cardBuilder: (context, index, _, __) {
                      final event = events[index];
                      return _buildSwipeableEventCard(event, index);
                    },
                    onSwipe: (previousIndex, currentIndex, direction) {
                      // Optional: Handle swipe actions
                      return true;
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Quick Stats Widget
  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Swipeable Modern Event Card
  Widget _buildSwipeableEventCard(app_event.Event event, int index) {
    final status = event.host == _userDisplayName
        ? 'host'
        : event.invitationStatus[_userId] ?? 'pending';

    Color iconColor;
    IconData icon;
    String statusText;

    switch (status) {
      case 'accepted':
        icon = Icons.check_circle;
        iconColor =
            const Color(0xFF10B981); // Success Green - Positive psychology
        statusText = 'You are attending';
        break;
      case 'declined':
        icon = Icons.cancel;
        iconColor = const Color(
            0xFFEF4444); // Soft Red - Less aggressive than harsh red
        statusText = 'You declined';
        break;
      case 'host':
        icon = Icons.star;
        iconColor =
            const Color(0xFFF59E0B); // Warm Orange - Energy & importance
        statusText = 'You are the host';
        break;
      default:
        icon = Icons.hourglass_empty;
        iconColor =
            const Color(0xFF64748B); // Slate Grey - Professional neutral
        statusText = 'Undecided';
    }

    final acceptedCount =
        event.invitationStatus.values.where((v) => v == 'accepted').length;
    final totalInvited = event.invitationStatus.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 400, // Fixed height for consistent swiping
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient
              Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withOpacity(0.8),
                      iconColor.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('MMM dd, yyyy • h:mm a')
                                  .format(event.dateTime),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status and attendance
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: iconColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Accepted: $acceptedCount / $totalInvited',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Action buttons
                        if (status == 'pending') ...[
                          _buildActionButton(
                            Icons.close,
                            const Color(0xFFEF4444),
                            () => _respondToEvent(event, 'declined'),
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            Icons.check,
                            const Color(0xFF10B981),
                            () => _respondToEvent(event, 'accepted'),
                          ),
                        ] else if (status == 'host') ...[
                          _buildActionButton(
                            Icons.cancel_outlined,
                            const Color(0xFFEF4444),
                            () => _showCancelEventDialog(event),
                          ),
                        ],
                      ],
                    ),
                    // Description if available
                    if (event.description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        event.description,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  void _respondToEvent(app_event.Event event, String response) async {
    if (_userId == null) return;

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(event.groupId)
        .collection('events')
        .doc(event.id)
        .update({
      'invitationStatus.$_userId': response,
    });
  }

  void _showCancelEventDialog(app_event.Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to cancel "${event.title}"?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                // Store the reason
              },
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
              _cancelEvent(event, 'Event cancelled by host');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Cancel Event',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _cancelEvent(app_event.Event event, String reason) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
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
