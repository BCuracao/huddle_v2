import 'package:flutter/material.dart';
import 'package:huddle/features/app/presentation/pages/home_page.dart';
import 'package:huddle/features/app/presentation/pages/calendar_page.dart';
import 'package:huddle/features/app/presentation/pages/group_viewer.dart';
import 'package:huddle/features/app/presentation/pages/edit_events_page.dart';
import 'package:huddle/features/app/presentation/widgets/enhanced_bottom_navigation.dart';

class MainNavigationController extends StatefulWidget {
  const MainNavigationController({super.key});

  @override
  State<MainNavigationController> createState() => _MainNavigationControllerState();
}

class _MainNavigationControllerState extends State<MainNavigationController>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;

  final List<Widget> _pages = [
    const HomePage(),
    const CalendarPage(),
    const GroupViewer(),
    const EditEventsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      
      // Smooth page transition
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
      
      // Trigger animation for visual feedback
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/events");
        },
        backgroundColor: const Color(0xFF8B5CF6), // Soft Purple
        shape: const CircleBorder(),
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: EnhancedBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        animationController: _animationController,
      ),
    );
  }
}
