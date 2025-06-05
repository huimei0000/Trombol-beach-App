import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context), // Navigate back
          ),
          title: const Text('My Rewards', style: TextStyle(color: Colors.black)),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.black),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/profile');
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.teal, // Changed tab indicator color
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.teal,
            tabs: [
              Tab(text: 'Available'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AvailableRewards(), // AvailableRewards will now handle its own context
            Center(child: Text("No past rewards yet")), // History tab content
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2, // Rewards is at index 2
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
              // Already on Rewards screen
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
      ),
    );
  }
}

class AvailableRewards extends StatelessWidget {
  const AvailableRewards({super.key});

  @override
  Widget build(BuildContext context) { // context is available here
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Available Rewards", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Filter tapped!")),
                  );
                  // TODO: Implement filter logic
                },
                icon: const Icon(Icons.filter_list, size: 18),
                label: const Text("Filter"),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _rewardCard( // Pass context here
                context, // Pass context as the first argument
                image: 'assets/images/new member point 50.jpeg',
                title: 'New Member 50 Points',
                expiry: 'Valid until 1 June 2025',
              ),
              _rewardCard( // Pass context here
                context, // Pass context as the first argument
                image: 'assets/images/voucher 100 points.jpeg',
                title: 'Voucher 100 Points',
                expiry: 'Valid until 25 July 2025',
              ),
              _rewardCard( // Pass context here
                context, // Pass context as the first argument
                image: 'assets/images/coupons 50 points.jpeg',
                title: 'Coupons 50 Points',
                expiry: 'Valid until 1 August 2025',
              ),
              _rewardCard( // Pass context here
                context, // Pass context as the first argument
                image: 'assets/images/free parking 10 points.jpg',
                title: 'Free Parking 10 Points',
                expiry: 'Valid until 1 September 2025',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Modified _rewardCard to accept BuildContext context as its first argument
  Widget _rewardCard(BuildContext context, {required String image, required String title, required String expiry}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to reward details page
          ScaffoldMessenger.of(context).showSnackBar( // context is now available here
            SnackBar(content: Text("Tapped on reward: $title")),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(image, width: 80, height: 80, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(expiry, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}


