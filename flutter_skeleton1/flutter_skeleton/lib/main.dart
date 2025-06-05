import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter_skeleton/screen/login_screen.dart';
import 'package:flutter_skeleton/screen/admin_dashboard.dart';
import 'package:flutter_skeleton/screen/user_dashboard.dart';
import 'package:flutter_skeleton/screen/forgot_password_screen.dart'; // This import should now work
import 'package:flutter_skeleton/screen/register_screen.dart';
import 'package:flutter_skeleton/screen/profile_screen.dart';
import 'package:flutter_skeleton/screen/rewards_screen.dart';
import 'package:flutter_skeleton/screen/orders_screen.dart';
import 'package:flutter_skeleton/screen/contact_us_screen.dart'; // This import should now work


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? _user;
  String? _userRole; // To store the user's role

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      setState(() {
        _user = user;
      });
      if (user != null) {
        // Fetch user role from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            _userRole = userDoc['role'];
          });
        } else {
          setState(() {
            _userRole = null; // Role not found
          });
        }
      } else {
        setState(() {
          _userRole = null; // No user logged in
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tropical Funland',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) {
          if (_user == null) {
            return const LoginScreen();
          } else {
            if (_userRole == 'admin') {
              return const AdminDashboard();
            } else if (_userRole == 'user') {
              return const UserDashboard();
            } else {
              // Handle case where role is not yet determined or invalid
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(), // Or a message like 'Determining role...'
                ),
              );
            }
          }
        },
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/adminDashboard': (context) => const AdminDashboard(),
        '/userDashboard': (context) => const UserDashboard(),
        '/profile': (context) => const ProfileScreen(),
        '/rewards': (context) => const RewardsScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/contact_us': (context) => const ContactUsScreen(),
      },
    );
  }
}
