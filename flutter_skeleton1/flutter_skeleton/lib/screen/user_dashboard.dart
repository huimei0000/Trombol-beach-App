import 'package:flutter/material.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {
                // TODO: Implement notification logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Notifications not yet implemented.")),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.black),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/profile');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hi User's Name section
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage('assets/images/profile.jpg'), // User's profile picture
                ),
                const SizedBox(width: 10),
                Text(
                  "Hi User's Name",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[800]),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Categories Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Disable scrolling for GridView
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.2, // Adjusted to make the boxes slightly wider than tall
              children: [
                _buildCategoryCard(context, 'Resorts', Icons.hotel),
                _buildCategoryCard(context, 'Shows & Events', Icons.event),
                _buildCategoryCard(context, 'Dining', Icons.restaurant),
                _buildCategoryCard(context, 'Shops', Icons.store),
              ],
            ),
            const SizedBox(height: 30),

            // Explore Tropical Paradise
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Explore Tropical Paradise",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal[800]),
                ),
                const Icon(Icons.location_on, color: Colors.teal),
              ],
            ),
            const SizedBox(height: 15),
            // Placeholder for explore content
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text(
                  "Map/Image Placeholder",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Home is at index 0
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFFD4F0EC),
        type: BottomNavigationBarType.fixed, // Ensures labels are always visible
        onTap: (index) {
          if (index == 0) {
            // Already on User Dashboard
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/orders'); // Navigate to Orders
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/rewards'); // Navigate to Rewards
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile'); // Navigate to Profile
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

  // _buildCategoryCard now has a larger icon size
  Widget _buildCategoryCard(BuildContext context, String title, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title tapped!")),
          );
          // TODO: Implement navigation to specific category pages
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.teal), // Icon size remains 60
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
