import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final String email;
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const ProfileScreen({
    Key? key,
    required this.username,
    required this.email,
    required this.onThemeChanged,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person, size: 100, color: Colors.deepPurple),
              const SizedBox(height: 20),

              Text(
                widget.username,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
              ),
              const SizedBox(height: 10),

              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Text(
                    widget.email,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 🔘 Dark/Light Mode Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.light_mode),
                  Switch(
                    value: _darkMode,
                    onChanged: (val) {
                      setState(() => _darkMode = val);
                      widget.onThemeChanged(val);
                    },
                  ),
                  const Icon(Icons.dark_mode),
                ],
              ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
