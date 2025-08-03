import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';
import 'package:huddle/features/app/controller/event_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../../global/common/custom_app_bar.dart';
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
  late DateTime date;

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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 110,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.5, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Container(
                    width: double.infinity,
                    height: 110,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3da8ad), Color(0xFF3da8ad)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
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
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
                child: Transform.translate(
                  offset: const Offset(0, -70),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF3da8ad),
                          Color(0xFF3da8ad),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF3da8ad),
                          blurRadius: 32,
                          offset: Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: const Color.fromARGB(255, 195, 216, 214)
                            .withOpacity(0.18),
                        width: 1.2,
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
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                        const SizedBox(height: 7),
                        TextField(
                          controller: _titleController,
                          style: const TextStyle(
                              color: Colors.teal, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: Colors.tealAccent, width: 1.2),
                            ),
                            hintText: 'Enter event name',
                            hintStyle:
                                TextStyle(color: Colors.teal.withOpacity(0.36)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Event Description',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                        const SizedBox(height: 7),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          style: const TextStyle(
                              color: Colors.teal, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: Colors.tealAccent, width: 1.2),
                            ),
                            hintText: 'Enter event description',
                            hintStyle:
                                TextStyle(color: Colors.teal.withOpacity(0.36)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Event Date & Time',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                        const SizedBox(height: 7),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() {
                                  date = DateTime(picked.year, picked.month,
                                      picked.day, time.hour, time.minute);
                                  _dateController.text =
                                      DateFormat('yyyy-MM-dd – kk:mm').format(date);
                                });
                              }
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: _dateController,
                              style: const TextStyle(
                                  color: Colors.teal, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                      color: Colors.tealAccent, width: 1.2),
                                ),
                                hintText: 'Pick date & time',
                                hintStyle:
                                    TextStyle(color: Colors.teal.withOpacity(0.36)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Invite Contacts',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                        const SizedBox(height: 7),
                        _availContacts.isEmpty
                            ? Center(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.contacts,
                                      color: Colors.tealAccent),
                                  label: const Text('Load Contacts'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.teal,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14))),
                                  onPressed: _loadContacts,
                                ),
                              )
                            : SizedBox(
                                height: 130,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: _availContacts.map((contact) {
                                    final selected =
                                        _selecContacts.contains(contact);
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: FilterChip(
                                        label: Text(contact.displayName ?? '',
                                            style: TextStyle(
                                                color: selected
                                                    ? Colors.white
                                                    : Colors.teal,
                                                fontWeight: FontWeight.w600)),
                                        avatar: CircleAvatar(
                                          backgroundColor: selected
                                              ? Colors.tealAccent
                                              : Colors.teal.withOpacity(0.18),
                                          child: Icon(
                                            selected ? Icons.check : Icons.person,
                                            color: selected
                                                ? Colors.teal
                                                : Colors.tealAccent,
                                            size: 18,
                                          ),
                                        ),
                                        backgroundColor: selected
                                            ? Colors.tealAccent.withOpacity(0.85)
                                            : Colors.white,
                                        selectedColor:
                                            Colors.tealAccent.withOpacity(0.95),
                                        elevation: selected ? 6 : 1,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                        selected: selected,
                                        onSelected: (bool value) {
                                          setState(() {
                                            if (value) {
                                              _selecContacts.add(contact);
                                            } else {
                                              _selecContacts.remove(contact);
                                            }
                                          });
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon:
                                const Icon(Icons.check_circle, color: Colors.white),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.tealAccent.shade700,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
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
                  ),
                ),
              ),
            ],
          ),
        ),
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
