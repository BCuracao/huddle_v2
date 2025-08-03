import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:huddle/features/app/model/event.dart' as app;
import 'package:firebase_auth/firebase_auth.dart';

class EventEditPage extends StatefulWidget {
  final app.Event event;
  const EventEditPage({super.key, required this.event});

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dateTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);
    _dateTime = widget.event.dateTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveEdits() async {
    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.displayName != widget.event.host) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only the host can edit this event.')),
      );
      setState(() => _isSaving = false);
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.event.groupId)
          .collection('events')
          .doc(widget.event.id)
          .update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'dateTime': Timestamp.fromDate(_dateTime),
      });
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update event: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Event')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Date & Time: '),
                TextButton(
                  child: Text('${_dateTime.year}-${_dateTime.month.toString().padLeft(2, '0')}-${_dateTime.day.toString().padLeft(2, '0')}  ${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')}'),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dateTime,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_dateTime),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _dateTime = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ],
            ),
            const Spacer(),
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
