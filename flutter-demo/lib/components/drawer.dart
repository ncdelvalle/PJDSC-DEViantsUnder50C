import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 240,
      backgroundColor: const Color(0xFFFFF8EF), // warm beige background
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              DrawerItem(
                icon: Icons.map_rounded,
                label: 'Hazard Map',
                onTap: () => Navigator.pushNamed(context, '/map'),
              ),
              const SizedBox(height: 20),
              DrawerItem(
                icon: Icons.route_rounded,
                label: 'Routes',
                onTap: () => Navigator.pushNamed(context, '/routes'),
              ),
              const SizedBox(height: 20),
              DrawerItem(
                icon: Icons.shield_rounded,
                label: 'Safety',
                onTap: () => Navigator.pushNamed(context, '/safety'),
              ),

              const Spacer(),
              const Divider(color: Colors.orangeAccent, thickness: 0.6),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(Icons.logout, color: Colors.orange),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/signin'),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
