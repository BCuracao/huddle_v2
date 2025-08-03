import 'package:flutter/material.dart';
import 'package:huddle/features/app/presentation/pages/contacts_selector.dart';
import 'package:huddle/features/app/presentation/pages/event_creation_page.dart';
import 'package:huddle/features/app/presentation/pages/group_viewer.dart';
import 'package:huddle/features/app/splash_screen/splash_screen.dart';
import 'package:huddle/features/app/presentation/pages/home_page.dart';
import 'package:huddle/features/app/presentation/pages/login_page.dart';
import 'package:huddle/features/app/presentation/pages/notifications_page.dart';
import 'package:huddle/features/app/presentation/pages/calendar_page.dart';
import 'package:huddle/features/app/presentation/pages/edit_events_page.dart'; // Assuming this is where EditEventsPage is located

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.white],
        ),
      ),
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'Montserrat',
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.tealAccent,
            secondary: const Color.fromARGB(
                254, 253, 199, 155), // Soft orange secondary
          ),
          scaffoldBackgroundColor: Colors.transparent,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        routes: {
          "/home": (context) => const HomePage(),
          "/login": (context) => const LoginPage(),
          "/groups": (context) => const GroupViewer(),
          "/events": (context) => const EventCreationPage(),
          "/contacts": (context) => const ContactsSelector(),
          "/notifications": (context) => const NotificationsPage(),
          "/calendar": (context) => const CalendarPage(),
          "/edit_event": (context) => const EditEventsPage(),
        },
        title: "Flutter Firebase",
        home: const SplashScreen(
          child: LoginPage(),
        ),
      ),
    );
  }
}
