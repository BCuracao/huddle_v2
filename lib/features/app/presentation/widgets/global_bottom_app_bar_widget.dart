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
                      color: Colors.tealAccent.withOpacity(0.7),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    )
                  : null,
              child: Icon(
                icon,
                size: 24,
                color: isActive ? Colors.white : Colors.teal[900],
              ),
            ),
            const SizedBox(height: 0),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.teal[900],
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
        gradient: LinearGradient(
          colors: [
            Colors.tealAccent[400]!,
            const Color.fromARGB(255, 122, 255, 222),
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
