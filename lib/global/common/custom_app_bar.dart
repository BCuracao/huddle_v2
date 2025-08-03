import 'package:flutter/material.dart';
import 'package:huddle/features/app/presentation/pages/profile_page.dart';
import 'package:huddle/features/app/presentation/pages/activity_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title = "",
    this.leading,
    this.titleWidget,
    required this.showActionIcon,
    this.onMenuActionTap,
    this.onActivityTap,
  });

  final String title;
  final Widget? leading;
  final Widget? titleWidget;
  final bool showActionIcon;
  final VoidCallback? onMenuActionTap;
  final VoidCallback? onActivityTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25 / 2.5),
        child: Stack(
          children: [
            Center(
              child: titleWidget ??
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: const Color.fromARGB(255, 61, 168, 173),
                      letterSpacing: 1.2,
                    ),
                  ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                leading ??
                    Transform.translate(
                      offset: const Offset(-14, 0),
                      child: IconButton(
                        icon: Icon(Icons.history,
                            color: const Color.fromARGB(255, 61, 168, 173),
                            size: 28),
                        onPressed: onActivityTap ??
                            () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ActivityPage(),
                                ),
                              );
                            },
                      ),
                    ),
                // Spacer to push the profile icon to the right
                const Spacer(),
                // User profile avatar on the right (interactive)
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.tealAccent.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      color: const Color.fromARGB(255, 61, 168, 173),
                    ),
                  ),
                ),
                // Removed burger menu (menu icon)
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size(
        double.maxFinite,
        80,
      );
}
