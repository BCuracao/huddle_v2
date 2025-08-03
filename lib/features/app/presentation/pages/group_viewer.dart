import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:huddle/features/app/model/group_model.dart';
import 'package:huddle/features/app/presentation/pages/contacts_selector.dart';
import 'package:huddle/features/app/presentation/pages/group_edit_page.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/global_bottom_app_bar_widget.dart';

// Retrieve FirebaseFirestore instance
final firestoreInstance = FirebaseFirestore.instance;

final groupModelInstance = GroupModel.instance;

class GroupViewer extends StatefulWidget {
  const GroupViewer({super.key});

  @override
  State<GroupViewer> createState() => _GroupViewerState();
}

class _GroupViewerState extends State<GroupViewer> {
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
              height: 700,
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
                      const Positioned(
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.groups_rounded,
                              color: Colors.white,
                              size: 42,
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Groups',
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
                                Text(
                                  'Connect & Collaborate',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ContactsSelector(),
                              ),
                            );
                          },
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
              padding: const EdgeInsets.only(top: 160.0, left: 0, right: 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: FutureBuilder<
                        List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                      future:
                          groupModelInstance.getUserGroups(currentUserRef!.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasData) {
                          final groups = snapshot.data!;
                          if (groups.isEmpty) {
                            return const Center(
                                child: Text(
                                    'No groups found. Click + to create one!'));
                          }
                          return PageView.builder(
                            itemCount: groups.length,
                            controller: PageController(viewportFraction: 0.88),
                            itemBuilder: (context, index) {
                              final group = groups[index].data();
                              final groupId = groups[index].id;
                              final groupName =
                                  group['groupName'] ?? 'Unnamed Group';
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0, vertical: 12.0),
                                child: Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white,
                                          Colors.white,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.tealAccent
                                              .withOpacity(0.12),
                                          blurRadius: 18,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                                255, 195, 216, 214)
                                            .withOpacity(0.22),
                                        width: 1.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 28),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const SizedBox(width: 18),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    groupName,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 26,
                                                      color: Colors.teal[900],
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  FutureBuilder<List<Contact>>(
                                                    future: _fetchGroupContacts(
                                                        groupId),
                                                    builder:
                                                        (context, contactSnap) {
                                                      if (contactSnap
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return Row(
                                                          children: [
                                                            Icon(Icons.people_outline,
                                                                size: 16,
                                                                color:
                                                                    Colors.teal[600]),
                                                            const SizedBox(
                                                                width: 6),
                                                            Text(
                                                              'Loading members...',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.teal[600],
                                                                fontSize: 14,
                                                                fontStyle:
                                                                    FontStyle.italic,
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                      if (contactSnap.hasData &&
                                                          contactSnap.data!
                                                              .isNotEmpty) {
                                                        final members =
                                                            contactSnap.data!;
                                                        return Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // Member count with icon
                                                            Row(
                                                              children: [
                                                                Icon(Icons.people,
                                                                    size: 18,
                                                                    color:
                                                                        Colors.teal[700]),
                                                                const SizedBox(
                                                                    width: 6),
                                                                Text(
                                                                  '${members.length} ${members.length == 1 ? 'Member' : 'Members'}',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors.teal[800],
                                                                    fontSize: 16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 6),
                                                            // Show first 2 members with nice styling
                                                            ...members
                                                                .take(2)
                                                                .map((member) =>
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .only(
                                                                          bottom:
                                                                              3),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Container(
                                                                            width:
                                                                                6,
                                                                            height:
                                                                                6,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color:
                                                                                  Colors.teal[400],
                                                                              shape:
                                                                                  BoxShape.circle,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              width:
                                                                                  8),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              member.displayName ??
                                                                                  'Unknown',
                                                                              style:
                                                                                  TextStyle(
                                                                                color:
                                                                                    Colors.teal[700],
                                                                                fontSize:
                                                                                    14,
                                                                                fontWeight:
                                                                                    FontWeight.w500,
                                                                              ),
                                                                              overflow:
                                                                                  TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ))
                                                                .toList(),
                                                            if (members.length >
                                                                2)
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                    left:
                                                                        14,
                                                                    top:
                                                                        2),
                                                                child:
                                                                    Text(
                                                                  '+${members.length - 2} more',
                                                                  style:
                                                                      TextStyle(
                                                                    color:
                                                                        Colors.teal[600],
                                                                    fontSize:
                                                                        12,
                                                                    fontStyle:
                                                                        FontStyle.italic,
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        );
                                                      }
                                                      return Row(
                                                        children: [
                                                          Icon(Icons.person_add_outlined,
                                                              size: 16,
                                                              color:
                                                                  Colors.grey[600]),
                                                          const SizedBox(
                                                              width: 6),
                                                          Text(
                                                            'No members yet',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey[600],
                                                              fontSize: 14,
                                                              fontStyle:
                                                                  FontStyle.italic,
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.person_add_alt_1),
                                              tooltip: 'Add contacts to group',
                                              onPressed: () =>
                                                  _showAddContactsDialog(
                                                      context, groupId),
                                              color: Colors.teal[700],
                                            ),
                                            // Edit group button
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.teal),
                                              tooltip: 'Edit Group',
                                              onPressed: () async {
                                                // Fetch contacts for this group
                                                final contacts =
                                                    await _fetchGroupContacts(
                                                        groupId);
                                                // Open edit page
                                                final result =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        GroupEditPage(
                                                      groupId: groupId,
                                                      initialGroupName:
                                                          groupName,
                                                      initialContacts: contacts,
                                                    ),
                                                  ),
                                                );
                                                if (result == true) {
                                                  setState(
                                                      () {}); // Refresh on save
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return const Center(child: Text('No data'));
                        }
                      },
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

  Future<List<Contact>> _fetchGroupContacts(String groupId) async {
    final userId = currentUserRef!.uid;
    final contactsSnap = await firestoreInstance
        .collection("users")
        .doc(userId)
        .collection("groups")
        .doc(groupId)
        .collection("contacts")
        .get();
    if (contactsSnap.docs.isEmpty) return [];
    List<Contact> contacts = [];
    for (final doc in contactsSnap.docs) {
      final name = doc.data()['contact'] as String?;
      if (name != null) {
        contacts.add(Contact()..displayName = name);
      }
    }
    return contacts;
  }

  void _showCreateGroupDialog(BuildContext context) {
    String groupName = '';
    List<Contact> selectedContacts = [];
    List<Contact> allContacts = [];
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create New Group'),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Group Name'),
                      onChanged: (val) => groupName = val,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.contacts),
                      label: const Text('Load Contacts'),
                      onPressed: () async {
                        PermissionStatus permission =
                            await Permission.contacts.request();
                        if (permission == PermissionStatus.granted) {
                          final contacts = await FlutterContacts.getContacts();
                          setState(() => allContacts = contacts);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    if (allContacts.isNotEmpty)
                      SizedBox(
                        height: 120,
                        child: ListView(
                          children: allContacts.map((contact) {
                            final selected = selectedContacts.contains(contact);
                            return CheckboxListTile(
                              value: selected,
                              title: Text(contact.displayName ?? ''),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    selectedContacts.add(contact);
                                  } else {
                                    selectedContacts.remove(contact);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(ctx),
                ),
                ElevatedButton(
                  child: const Text('Create'),
                  onPressed: () async {
                    if (groupName.trim().isEmpty) return;
                    await _storeGroupInformation(groupName, selectedContacts);
                    Navigator.pop(ctx);
                    setState(() {}); // Refresh group list
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _storeGroupInformation(
      String groupName, List<Contact> selectedContacts) async {
    final userId = currentUserRef!.uid;
    final groupRef = firestoreInstance
        .collection("users")
        .doc(userId)
        .collection("groups")
        .doc();
    await groupRef.set({"groupName": groupName});
    for (final contact in selectedContacts) {
      await groupRef
          .collection("contacts")
          .add({"contact": contact.displayName});
    }
  }

  void _showAddContactsDialog(BuildContext context, String groupId) {
    List<Contact> selectedContacts = [];
    List<Contact> allContacts = [];
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Contacts to Group'),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.contacts),
                      label: const Text('Load Contacts'),
                      onPressed: () async {
                        PermissionStatus permission =
                            await Permission.contacts.request();
                        if (permission == PermissionStatus.granted) {
                          final contacts = await FlutterContacts.getContacts();
                          setState(() => allContacts = contacts);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    if (allContacts.isNotEmpty)
                      SizedBox(
                        height: 120,
                        child: ListView(
                          children: allContacts.map((contact) {
                            final selected = selectedContacts.contains(contact);
                            return CheckboxListTile(
                              value: selected,
                              title: Text(contact.displayName ?? ''),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    selectedContacts.add(contact);
                                  } else {
                                    selectedContacts.remove(contact);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(ctx),
                ),
                ElevatedButton(
                  child: const Text('Add'),
                  onPressed: () async {
                    await _addContactsToGroup(groupId, selectedContacts);
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addContactsToGroup(
      String groupId, List<Contact> selectedContacts) async {
    final userId = currentUserRef!.uid;
    final groupRef = firestoreInstance
        .collection("users")
        .doc(userId)
        .collection("groups")
        .doc(groupId);
    for (final contact in selectedContacts) {
      await groupRef
          .collection("contacts")
          .add({"contact": contact.displayName});
    }
  }
}
