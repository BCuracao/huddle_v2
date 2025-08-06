import 'package:flutter/material.dart';
import 'package:huddle/features/app/presentation/pages/contacts_selector.dart';
import 'package:huddle/features/app/presentation/pages/event_creation_page.dart';
import 'package:huddle/features/app/presentation/pages/notifications_page.dart';
import 'package:huddle/features/app/splash_screen/splash_screen.dart';
import 'package:huddle/features/app/presentation/pages/login_page.dart';
import 'package:huddle/features/app/presentation/widgets/main_navigation_controller.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
          "/main": (context) => const MainNavigationController(),
          "/login": (context) => const LoginPage(),
          "/events": (context) => const EventCreationPage(),
          "/contacts": (context) => const ContactsSelector(),
          "/notifications": (context) => const NotificationsPage(),
        },
        title: "Flutter Firebase",
        home: const SplashScreen(
          child: LoginPage(),
        ),
      ),
    );
  }
}
