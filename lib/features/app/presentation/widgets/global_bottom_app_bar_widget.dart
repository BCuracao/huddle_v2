import 'dart:ui';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';

class GlobalBottomAppBarWidget extends StatefulWidget {
  const GlobalBottomAppBarWidget({super.key});

  @override
  State<GlobalBottomAppBarWidget> createState() =>
      _GlobalBottomAppBarWidgetState();
}

class _GlobalBottomAppBarWidgetState extends State<GlobalBottomAppBarWidget> {
  List<Contact> userGroup = [];

  @override
  Widget build(BuildContext context) {
    final String? currentRoute = ModalRoute.of(context)?.settings.name;
    Widget buildBarItem({
      required IconData icon,
      required String label,
      required String route,
    }) {
      final bool isActive = currentRoute == route;
      return GestureDetector(
        onTap: () {
          if (currentRoute != route) {
            Navigator.of(context).pushNamed(route);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: isActive
                  ? BoxDecoration(
                      color: const Color(0xFFF59E0B)
                          .withOpacity(0.95), // Warm Orange - Energy & Action
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    )
                  : null,
              child: Icon(
                icon,
                size: 24,
                color: isActive
                    ? Colors.white
                    : const Color(0xFF2D2D2D), // Dark text
              ),
            ),
            const SizedBox(height: 0),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : const Color(0xFF2D2D2D), // Dark text
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A8A), // Deep Blue - Trust & Reliability
            Color(0xFF8B5CF6), // Soft Purple - Social & Creative
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            child: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              elevation: 16,
              color: Colors.transparent, // Keep transparent for blur/gradient
              child: SizedBox(
                height: kBottomNavigationBarHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildBarItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        route: '/home'),
                    buildBarItem(
                        icon: Icons.event_note_rounded,
                        label: 'Calendar',
                        route: '/calendar'),
                    buildBarItem(
                        icon: Icons.groups_rounded,
                        label: 'Groups',
                        route: '/groups'),
                    buildBarItem(
                        icon: Icons.edit_note_rounded,
                        label: 'Edit',
                        route: '/edit_event'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
