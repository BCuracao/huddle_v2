import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isUploading = false;
  String? _uploadedUrl;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile == null) return;
    setState(() => _isUploading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final ref = FirebaseStorage.instance.ref().child('profile_pics/${user.uid}.jpg');
      await ref.putData(await pickedFile.readAsBytes());
      final url = await ref.getDownloadURL();
      await user.updatePhotoURL(url);
      setState(() {
        _uploadedUrl = url;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = _uploadedUrl ?? user?.photoURL;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.tealAccent.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Stack(
              children: [
                CircleAvatar(
                  radius: 56,
                  backgroundColor: Colors.tealAccent.withOpacity(0.2),
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                      ? NetworkImage(photoUrl)
                      : null,
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? Icon(Icons.person, color: Colors.tealAccent.shade700, size: 56)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _isUploading ? null : _pickAndUploadImage,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: _isUploading
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : const Icon(Icons.camera_alt, color: Colors.tealAccent),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              user?.displayName ?? user?.email ?? 'Anonymous',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
