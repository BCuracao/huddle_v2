import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:huddle/features/app/model/group_model.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../global/common/custom_app_bar.dart';
import '../widgets/global_bottom_app_bar_widget.dart';

// Retrieve FirebaseFirestore instance
final firestoreInstance = FirebaseFirestore.instance;

// Retrieve Reference of current user
final currentUserRef = FirebaseAuth.instance.currentUser;

final groupModelInstance = GroupModel.instance;

class ContactsSelector extends StatefulWidget {
  const ContactsSelector({super.key});

  @override
  _ContactsSelectorState createState() => _ContactsSelectorState();
}

class _ContactsSelectorState extends State<ContactsSelector> {
  List<Contact> _contacts = [];
  final List<Contact> _selectedContacts = [];

  late String _groupName;

  @override
  void initState() {
    super.initState();
    getContacts();
  }

  Future<void> getContacts() async {
    PermissionStatus permission = await Permission.contacts.request();

    if (permission == PermissionStatus.granted) {
      if (await FlutterContacts.requestPermission()) {
        List<Contact> contacts = await FlutterContacts.getContacts();
        setState(() {
          _contacts = contacts;
        });
      }
    } else {
      // Handle permission denied
    }
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: CustomAppBar(
        leading: Icon(
          Icons.home,
          color: Colors.grey.shade600.withOpacity(0.5),
        ),
        showActionIcon: true,
      ),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          Contact contact = _contacts[index];
          return SingleChildScrollView(
            child: ListTile(
              title: Text(contact.displayName),
              trailing: Checkbox(
                value: _selectedContacts.contains(contact),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedContacts.add(contact);
                    } else {
                      _selectedContacts.remove(contact);
                    }
                  });
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const GlobalBottomAppBarWidget(),
    );
  }

  Future<void> storeGroupInformation() async {
    groupModelInstance.addGroup(_groupName, _selectedContacts);

    String userId = currentUserRef!.uid;
    firestoreInstance.collection("users").doc(userId);

    String groupId = firestoreInstance
        .collection("users")
        .doc(userId)
        .collection("groups")
        .doc()
        .id;

    firestoreInstance
        .collection("users")
        .doc(userId)
        .collection("groups")
        .doc(groupId)
        .set({"groupName:": _groupName});

    for (int i = 0; i < _selectedContacts.length; i++) {
      firestoreInstance
          .collection("users")
          .doc(userId)
          .collection("groups")
          .doc(groupId)
          .collection("contacts")
          .add({"contact": _selectedContacts[i].displayName});
    }
  }
}
