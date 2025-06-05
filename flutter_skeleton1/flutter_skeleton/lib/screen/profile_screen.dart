import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logged out successfully!")),
      );
      Navigator.pushReplacementNamed(context, '/login'); // Navigate back to login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // Navigate back
        ),
        title: const Text('Profile Page', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {
              // Already on profile, perhaps refresh or show profile details
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User's Name and Profile Picture
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/profile.jpg'), // User's profile picture
                  ),
                  const SizedBox(height: 10),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? "User's Name", // Display logged-in user's email
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // List of options
            _buildOptionTile(context, 'Edit Details', Icons.edit, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Edit Details tapped!")),
              );
              // TODO: Navigate to Edit Details screen
            }),
            _buildOptionTile(context, 'Settings', Icons.settings, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Settings tapped!")),
              );
              // TODO: Navigate to Settings screen
            }),
            _buildOptionTile(context, 'Contact Us', Icons.help_outline, () {
              Navigator.pushNamed(context, '/contact'); // Navigate to Contact Us screen
            }),
            _buildOptionTile(context, 'About', Icons.info_outline, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("About tapped!")),
              );
              // TODO: Navigate to About screen
            }),
            const SizedBox(height: 30),

            // Logout button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Changed color for logout
                  elevation: 2,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _logout(context), // Call Firebase logout
                child: const Text("Logout", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Profile is at index 3
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFFD4F0EC),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/userDashboard'); // Navigate to Home
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/orders'); // Navigate to Orders
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/rewards'); // Navigate to Rewards
          } else if (index == 3) {
            // Already on Profile screen
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Rewards'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
