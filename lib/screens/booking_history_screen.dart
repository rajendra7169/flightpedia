import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  BottomNavigationBar _buildBottomNavigationBar(
      BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.airplane_ticket), label: 'Ticket'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
      ],
      onTap: (index) {
        if (index == 0) {
          Navigator.pushNamed(context, '/home');
        } else if (index == 1) {
          Navigator.pushNamed(context, '/ticket');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/setting');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Booking History',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background_tickets.jpg'), // Add your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.4), // Increased blur effect
          ),
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 20),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('userId', isEqualTo: user?.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error loading booking history',
                          style: TextStyle(color: Colors.white)));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data?.docs.length ?? 0,
                  itemBuilder: (context, index) {
                    final booking = snapshot.data!.docs[index];
                    final data = booking.data() as Map<String, dynamic>;
                    return _buildHistoryItem(data, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, 2),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> booking, BuildContext context) {
    final flight = booking['flight'] as Map<String, dynamic>;
    final date = (booking['timestamp'] as Timestamp).toDate();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.black.withOpacity(0.5), // Darker box color
      elevation: 8,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(flight['airline'], style: TextStyle(color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${flight['departureCity']} - ${flight['arrivalCity']}',
                style: TextStyle(color: Colors.white)),
            Text(DateFormat('MMM dd, yyyy hh:mm a').format(date),
                style: TextStyle(color: Colors.white70)),
            Text('NPR ${booking['totalPrice'].toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.receipt, color: Colors.white),
          onPressed: () {
            if (booking['pdfPath'] != null) {
              OpenFile.open(booking['pdfPath']);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ticket PDF not found')),
              );
            }
          },
        ),
      ),
    );
  }
}
