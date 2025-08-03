import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupEditPage extends StatefulWidget {
  final String groupId;
  final String initialGroupName;
  final List<Contact> initialContacts;
  const GroupEditPage(
      {super.key,
      required this.groupId,
      required this.initialGroupName,
      required this.initialContacts});

  @override
  State<GroupEditPage> createState() => _GroupEditPageState();
}

class _GroupEditPageState extends State<GroupEditPage> {
  late TextEditingController _nameController;
  late List<Contact> _selectedContacts;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialGroupName);
    _selectedContacts = List<Contact>.from(widget.initialContacts);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveEdits() async {
    setState(() => _isSaving = true);
    final userId = FirebaseFirestore
        .instance.app.options.projectId; // Replace with your user id logic
    try {
      // Update group name
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('groups')
          .doc(widget.groupId)
          .update({'groupName': _nameController.text});
      // Update contacts (for simplicity, remove all and re-add)
      final contactsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('groups')
          .doc(widget.groupId)
          .collection('contacts');
      final contactsSnap = await contactsRef.get();
      for (final doc in contactsSnap.docs) {
        await doc.reference.delete();
      }
      for (final contact in _selectedContacts) {
        await contactsRef.add({'contact': contact.displayName});
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update group: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Group'),
        backgroundColor: Colors.tealAccent.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            const SizedBox(height: 16),
            const Text('Contacts:'),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedContacts.length,
                itemBuilder: (context, idx) {
                  final contact = _selectedContacts[idx];
                  return ListTile(
                    title: Text(contact.displayName),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedContacts.removeAt(idx);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveEdits,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
