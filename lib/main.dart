import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flightpedia/services/passenger_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/booking_history_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import '../services/flight_results_screen.dart';
import '../services/flight_service.dart';
import '../services/flight_results_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/change_pin_screen.dart';
import 'screens/tickets_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white, // Default background color
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            if (user == null) return LoginScreen();
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.hasData) {
                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  return HomeScreen(
                    userName: userData['fullName'] ?? 'User',
                  );
                }
                return const CircularProgressIndicator();
              },
            );
          }
          return const CircularProgressIndicator();
        },
      ),
      initialRoute: '/home',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => HomeScreen(userName: ''),
        '/flight-results': (context) => FlightResultsScreen(
              departureCity: '',
              arrivalCity: '',
              departureDate: DateTime.now(),
              adults: 1,
              children: 0,
              flights: [],
            ),
        '/passenger-details': (context) => PassengerDetailsScreen(
              flight: {},
              totalPassengers: 1,
              adults: 1,
              children: 0,
              totalPrice: 0.0,
            ),
        '/setting': (context) => SettingScreen(),
        '/ticket': (context) => const TicketsScreen(),
        '/history': (context) => const BookingHistoryScreen(),
        '/edit-profile': (context) => EditProfileScreen(),
        '/change-password': (context) => ChangePasswordScreen(),
        '/change-pin': (context) => ChangePinScreen(),
      },
    );
  }
}
