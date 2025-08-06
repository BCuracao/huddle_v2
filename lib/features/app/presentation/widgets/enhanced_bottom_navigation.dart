import 'dart:ui';
import 'package:flutter/material.dart';

class EnhancedBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final AnimationController animationController;

  const EnhancedBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
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
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            elevation: 0,
            color: Colors.transparent,
            child: SizedBox(
              height: kBottomNavigationBarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.event_note_rounded,
                    label: 'Calendar',
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: Icons.groups_rounded,
                    label: 'Groups',
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: Icons.edit_note_rounded,
                    label: 'Edit',
                    index: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: isActive ? 1.0 + (animationController.value * 0.1) : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOutCubic,
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
                        : const Color(0xFF2D2D2D).withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOutCubic,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : const Color(0xFF2D2D2D).withOpacity(0.7),
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
