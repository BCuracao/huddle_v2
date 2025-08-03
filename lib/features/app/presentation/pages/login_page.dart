import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:huddle/features/app/presentation/pages/sign_up_page.dart';
import 'package:huddle/features/app/presentation/widgets/form_container_widget.dart';
import 'package:huddle/global/common/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/group_model.dart';
import '../../user_auth/firebase_auth_implementation/firebase_auth_services.dart';

final groupModelInstance = GroupModel.instance;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Preloaded events cache
  List<dynamic>? _preloadedEvents;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _preloadEventsForUser(String userId, String? userDisplayName) async {
    // Find groups the user is a member of
    final userGroupsSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('groups')
        .get();
    final groupIds = userGroupsSnap.docs.map((d) => d.id).toList();
    List<dynamic> events = [];
    for (final groupId in groupIds) {
      final eventsSnap = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('events')
          .get();
      for (final doc in eventsSnap.docs) {
        final data = doc.data();
        // Use dynamic or import Event if available
        if (userDisplayName != null && (data['host'] == userDisplayName || (data['invitationStatus'] ?? {}).containsKey(userId))) {
          events.add(data);
        }
      }
    }
    return events;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Hero image
                  Container(
                    height: 275,
                    width: 275,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Image.asset(
                      'assets/images/huddle_login_1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(
                    'Huddle up!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF3facaf),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FormContainerWidget(
                    controller: _emailController,
                    hintText: 'Email',
                    isPasswordField: false,
                  ),
                  const SizedBox(height: 16),
                  FormContainerWidget(
                    controller: _passwordController,
                    hintText: 'Password',
                    isPasswordField: true,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Implement forgot password
                        showToast(message: 'Forgot password tapped');
                      },
                      child: Text(
                        'Forgot password?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: _isLoading ? null : _signIn,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFFffbf84),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                'Login',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                            ((route) => false),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signIn() async {
    setState(() {
      _isLoading = true;
    });
    String email = _emailController.text;
    String password = _passwordController.text;
    User? user = await _auth.signInWithEmailAndPassword(email, password);
    if (user != null) {
      // Preload events during login
      String? displayName = user.displayName ?? user.email;
      _preloadedEvents = await _preloadEventsForUser(user.uid, displayName);
    }
    groupModelInstance.getUserGroups(user!.uid).then((groupDocs) {
      for (var doc in groupDocs) {
        groupModelInstance.groupData = doc.data();
      }
    }).catchError((error) {
      print('Error getting groups:  + $error');
    });
    showToast(message: 'User is successfully signedIn');
    if (!mounted) return;
    Navigator.pushNamed(context, '/home', arguments: _preloadedEvents);
    setState(() {
      _isLoading = false;
    });
  }
}
