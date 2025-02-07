import 'package:flightpedia/screens/change_password_screen.dart';
import 'package:flightpedia/screens/change_pin_screen.dart';
import 'package:flightpedia/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background_setting.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.8),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (user != null)
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}',
                              style: TextStyle(color: Colors.white));
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Text('User data not found.',
                              style: TextStyle(color: Colors.white));
                        }

                        final userData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        final fullName = userData['fullName'] ?? 'No Name';
                        final email = userData['email'] ?? 'No Email';

                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: AssetImage('assets/profile.png'),
                            ),
                            SizedBox(height: 12),
                            Text(
                              fullName,
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              email,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white70),
                            ),
                            SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color:
                          Colors.white.withOpacity(0.3), // More standout effect
                      borderRadius:
                          BorderRadius.circular(16), // More rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 30,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingsTile(context, Icons.edit, 'Edit Profile',
                            EditProfileScreen()),
                        _buildSettingsTile(context, Icons.lock,
                            'Change Password', ChangePasswordScreen()),
                        _buildSettingsTile(context, Icons.pin, 'Change PIN',
                            ChangePinScreen()),
                        _buildSettingsTile(
                            context, Icons.language, 'Change Language', null),
                        ListTile(
                          leading: Icon(Icons.logout, color: Colors.red),
                          title: Text('Sign Out',
                              style: TextStyle(color: Colors.red)),
                          onTap: () => _signOut(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, 3),
    );
  }

  Widget _buildSettingsTile(
      BuildContext context, IconData icon, String title, Widget? page) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 52, 120, 245)),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: page != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            }
          : null,
    );
  }

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
          Navigator.pushReplacementNamed(context, '/home');
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/ticket');
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/history');
        }
      },
    );
  }
}
