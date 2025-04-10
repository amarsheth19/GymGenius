import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'main.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Profile"),
            actions: [
              _buildAuthAction(context, user),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user == null)
                    const Center(child: Text("Please sign in to view your profile"))
                  else ...[
                    _buildProfileInfo(user),
                    const SizedBox(height: 20),
                    _buildStreakSection({"Current Streak": 7, "Longest Streak": 14}),
                    const SizedBox(height: 20),
                    _buildBadgesSection(),
                    const SizedBox(height: 20),
                    _buildProfileStatus(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthAction(BuildContext context, User? user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: GestureDetector(
          onTap: () async {
            if (user != null) {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
                (route) => false,
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                user != null ? Icons.logout : Icons.login,
                color: Colors.black,
              ),
              const SizedBox(width: 4),
              Text(
                user != null ? "Log out" : "Sign in",
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user.photoURL != null)
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(user.photoURL!),
          ),
        const SizedBox(height: 16),
        Text(
          user.displayName ?? "User",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 8),
        Text(user.email ?? "No email"),
      ],
    );
  }

  Widget _buildStreakSection(Map<String, int> streaks) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: streaks.entries
          .map((e) => _buildStreakInfo(e.key, e.value))
          .toList(),
    );
  }

  Widget _buildStreakInfo(String label, int streakDays) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.whatshot, color: Colors.redAccent, size: 24),
            const SizedBox(width: 8),
            Text("$streakDays days", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Badges",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        _buildBadgeInfo("Bench 225"),
      ],
    );
  }

  Widget _buildBadgeInfo(String badgeName) {
    return Row(
      children: [
        const Icon(Icons.emoji_events, color: Colors.yellowAccent, size: 24),
        const SizedBox(width: 8),
        Text(badgeName, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildProfileStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Profile Status",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.grey, size: 24),
            const SizedBox(width: 8),
            const Text("Silver Tier", style: TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }
}
