import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';
import 'package:huddle/features/app/controller/event_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:huddle/features/app/presentation/widgets/global_bottom_app_bar_widget.dart';

class EventCreationPage extends StatefulWidget {
  const EventCreationPage({super.key});

  @override
  State<EventCreationPage> createState() => _EventCreationPageState();
}

class _EventCreationPageState extends State<EventCreationPage> {
  final controller = EventController();
  List<Contact> _availContacts = [];
  final List<Contact> _selecContacts = [];
  DateTime date = DateTime.now();

  String? _selectedGroupId;
  String? _selectedGroupName;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
  }

  _checkPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      // Load contacts if permission is granted
      _loadContacts();
    }
  }

  _loadContacts() async {
    Iterable<Contact> contacts =
        await FlutterContacts.getContacts(withThumbnail: false);
    setState(() {
      _availContacts = contacts.toList();
    });
  }

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _selectedGroupId = args != null ? args['groupId'] as String? : null;
    _selectedGroupName = args != null ? args['groupName'] as String? : null;
    return Scaffold(
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
      bottomNavigationBar: const GlobalBottomAppBarWidget(),
      backgroundColor: Colors.grey.shade50,
      extendBody: true,
      body: Stack(
        children: [
          // Modern gradient header matching home page
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.transparent,
                ],
                stops: [1, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: Container(
              height: 700,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.tealAccent[400]!,
                    const Color.fromARGB(255, 122, 255, 222),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(128),
                  bottomRight: Radius.circular(128),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 20.0),
                  child: Stack(
                    children: [
                      // Title positioned at top
                      const Positioned(
                        top: 10,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.event_note,
                              color: Colors.white,
                              size: 32,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Create Event',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Subtitle
                      const Positioned(
                        top: 55,
                        left: 44,
                        child: Text(
                          'Plan & Invite',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content area with proper spacing
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 200), // Space for header
                // Modern floating form card
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.teal.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedGroupName != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.groups,
                                  color: Color(0xFF3da8ad), size: 26),
                              const SizedBox(width: 8),
                              Text(
                                _selectedGroupName!,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal[900]),
                              ),
                            ],
                          ),
                        ),
                      const Text(
                        'Event Title',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.teal),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                            color: Colors.black87, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.grey[300]!, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.grey[300]!, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.teal, width: 2),
                          ),
                          hintText: 'Enter event name',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 0),
                      const Text(
                        'Event Description',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.teal),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 3,
                        style: const TextStyle(
                            color: Colors.black87, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.grey[300]!, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.grey[300]!, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.teal, width: 2),
                          ),
                          hintText: 'Enter event description',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 0),
                      const Text(
                        'Date & Time',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.teal),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() {
                                    date = DateTime(picked.year, picked.month,
                                        picked.day, date.hour, date.minute);
                                    _dateController.text =
                                        DateFormat('MMM dd, yyyy').format(date);
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey[300]!, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        color: Colors.grey[600], size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _dateController.text.isNotEmpty
                                            ? _dateController.text
                                            : 'Select date',
                                        style: TextStyle(
                                          color: _dateController.text.isNotEmpty
                                              ? Colors.black87
                                              : Colors.grey[500],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null) {
                                  setState(() {
                                    date = DateTime(date.year, date.month,
                                        date.day, time.hour, time.minute);
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey[300]!, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        color: Colors.grey[600], size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        date != null
                                            ? DateFormat('HH:mm').format(date)
                                            : 'Time',
                                        style: TextStyle(
                                          color: date != null
                                              ? Colors.black87
                                              : Colors.grey[500],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Text(
                            'Invite Contacts',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.teal),
                          ),
                          const Spacer(),
                          if (_selecContacts.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.teal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_selecContacts.length} selected',
                                style: TextStyle(
                                  color: Colors.teal[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _availContacts.isEmpty
                          ? GestureDetector(
                              onTap: _loadContacts,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey[300]!, width: 1),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.contacts,
                                        color: Colors.grey[600], size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Load Contacts',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              height: 100,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey[300]!, width: 1),
                              ),
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: _availContacts.map((contact) {
                                  final selected =
                                      _selecContacts.contains(contact);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (selected) {
                                            _selecContacts.remove(contact);
                                          } else {
                                            _selecContacts.add(contact);
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: 70,
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? Colors.teal.withOpacity(0.1)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: selected
                                                ? Colors.teal
                                                : Colors.grey[300]!,
                                            width: selected ? 2 : 1,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor: selected
                                                  ? Colors.teal
                                                  : Colors.grey[300],
                                              child: Icon(
                                                selected
                                                    ? Icons.check
                                                    : Icons.person,
                                                color: selected
                                                    ? Colors.white
                                                    : Colors.grey[600],
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              contact.displayName
                                                      ?.split(' ')
                                                      .first ??
                                                  'Unknown',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: selected
                                                    ? Colors.teal[700]
                                                    : Colors.grey[700],
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: Colors.grey[400]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.event_available,
                                  color: Colors.white, size: 18),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                _createEvent(_selecContacts);
                              },
                              label: const Text('Create Event'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // Bottom spacing for FAB
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _createEvent(List<Contact> selecContacts) async {
    if (_selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No group selected.')),
      );
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final id = FirebaseFirestore.instance
        .collection('groups')
        .doc(_selectedGroupId)
        .collection('events')
        .doc()
        .id;
    final title = _titleController.text;
    final host = user.displayName ?? user.email ?? '';
    final hostProfileUrl = user.photoURL ?? '';
    final location = ''; // You may want to add location input
    final description = _descriptionController.text;
    final invitationStatus = <String, String>{
      for (var c in selecContacts) c.id: 'pending'
    };
    controller.createEvent(
      id: id,
      title: title,
      host: host,
      hostProfileUrl: hostProfileUrl,
      location: location,
      dateTime: date,
      attendees: selecContacts,
      groupId: _selectedGroupId!,
      invitationStatus: invitationStatus,
      description: description,
    );
    Navigator.pop(context);
  }
}
