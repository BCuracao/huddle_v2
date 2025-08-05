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

  Future<List<dynamic>> _preloadEventsForUser(
      String userId, String? userDisplayName) async {
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
        if (userDisplayName != null &&
            (data['host'] == userDisplayName ||
                (data['invitationStatus'] ?? {}).containsKey(userId))) {
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
      backgroundColor:
          const Color(0xFFF8FAFC), // Clean background like home page
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC), // Clean background
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Hero section with modern gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1E3A8A), // Deep Blue - Trust & reliability
                          Color(0xFF8B5CF6), // Soft Purple - Social connection
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(32), // Modern organic curves
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    height: 350,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Restore the original image with modern styling
                          SizedBox(
                            width: 300,
                            height: 300,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/images/huddle_login_1.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Connect • Plan • Celebrate',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    'Welcome Back!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF2D2D2D), // Modern dark text
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your account',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color:
                          const Color(0xFF64748B), // Slate grey like home page
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
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
                          color: const Color(
                              0xFF8B5CF6), // Purple accent like home page
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: _isLoading ? null : _signIn,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(24), // Modern organic curves
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFF59E0B), // Warm Orange - Energy & action
                            Color(0xFFFF8A00), // Slightly deeper orange
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              )
                            : Text(
                                'Sign In',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 0.8,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(
                              0xFF64748B), // Slate grey like home page
                          fontSize: 15,
                        ),
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
                            color: const Color(0xFF8B5CF6), // Purple accent
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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
