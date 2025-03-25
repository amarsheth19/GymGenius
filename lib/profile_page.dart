import 'package:flutter/material.dart';
import 'login_page.dart'; 

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          // Login Button in the AppBar
          IconButton(
            icon: Icon(Icons.account_box_rounded), //choose icon from lib
            onPressed: () {
              // Navigate to the LoginPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Information
              _buildProfileInfo(),
              SizedBox(height: 20),

              // Current Streak and Longest Streak
              _buildStreakSection(),
              SizedBox(height: 20),

              // Badges Section
              _buildBadgesSection(),
              SizedBox(height: 20),

              // Profile Status Section (Tier)
              _buildProfileStatus(),
            ],
          ),
        ),
      ),
    );
  }

  // Profile Information Section
  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "John Doe",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        SizedBox(height: 8),
        Text("Height: 5'10\" | Weight: 175 lbs | Age: 25 | Sex: Male"),
      ],
    );
  }

  // Streak Section (Current & Longest Streak)
  Widget _buildStreakSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStreakInfo("Current Streak", 7),
        _buildStreakInfo("Longest Streak", 14),
      ],
    );
  }

  // Streak Info Helper
  Widget _buildStreakInfo(String label, int streakDays) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.whatshot,
              color: Colors.redAccent,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              "$streakDays days",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  // Badges Section
  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Badges",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 10),
        _buildBadgeInfo("Bench 225"),
      ],
    );
  }

  // Badge Info Helper
  Widget _buildBadgeInfo(String badgeName) {
    return Row(
      children: [
        Icon(
          Icons.emoji_events,
          color: Colors.yellowAccent,
          size: 24,
        ),
        SizedBox(width: 8),
        Text(
          badgeName,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  // Profile Status Section (User Tier)
  Widget _buildProfileStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Profile Status",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Icon(
              Icons.star,
              color: Colors.grey,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              "Silver Tier",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}