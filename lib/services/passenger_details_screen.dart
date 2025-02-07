import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PassengerDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> flight;
  final int totalPassengers;
  final int adults;
  final int children;
  final double totalPrice;

  const PassengerDetailsScreen({
    super.key,
    required this.flight,
    required this.totalPassengers,
    required this.adults,
    required this.children,
    required this.totalPrice,
  });

  @override
  _PassengerDetailsScreenState createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<Map<String, dynamic>> _passengers;

  @override
  void initState() {
    super.initState();
    _passengers = List.generate(
        widget.totalPassengers,
        (index) => {
              'name': '',
              'passportNumber': '',
              'phoneNumber': '',
              'type': index < widget.adults ? 'Adult' : 'Child'
            });
  }

  Future<void> _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('User not authenticated');

        // Generate PDF
        final pdf = await _generatePdf();
        final filePath = await _savePdfLocally(pdf);

        final timestamp = DateTime.now();
        final fileName = 'ticket_${timestamp.millisecondsSinceEpoch}.pdf';

        // Save to Firestore WITH pdfPath
        await FirebaseFirestore.instance.collection('bookings').add({
          'userId': user.uid,
          'flight': widget.flight,
          'passengers': _passengers,
          'totalPrice': widget.totalPrice,
          'timestamp': FieldValue.serverTimestamp(),
          'pdfPath': filePath, // Add this line to save the PDF path
        });

        _showSuccessDialog(filePath);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<String> _savePdfLocally(Uint8List pdf) async {
    final dir = await getApplicationDocumentsDirectory();
    final file =
        File('${dir.path}/ticket_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(pdf);
    return file.path;
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(text: 'Flight Ticket', level: 1),
            pw.Text('Airline: ${widget.flight['airline']}'),
            pw.Text('Flight Number: ${widget.flight['flightNumber']}'),
            pw.Divider(),
            pw.Text(
                'Departure: ${widget.flight['departureTime']} (${widget.flight['departureCity']})'),
            pw.Text(
                'Arrival: ${widget.flight['arrivalTime']} (${widget.flight['arrivalCity']})'),
            pw.SizedBox(height: 20),
            pw.Header(text: 'Passengers', level: 2),
            ..._passengers.map((p) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Name: ${p['name']}'),
                      pw.Text('Passport: ${p['passportNumber']}'),
                      pw.Text('Type: ${p['type']}'),
                      pw.Divider(),
                    ])),
            pw.SizedBox(height: 20),
            pw.Text('Total Price: NPR ${widget.totalPrice.toStringAsFixed(2)}',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  void _showSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ticket saved to:'),
            Text(filePath, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Home'),
          ),
          TextButton(
            onPressed: () => OpenFile.open(filePath),
            child: const Text('Open Ticket'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Passenger Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView.builder(
            itemCount: _passengers.length,
            itemBuilder: (context, index) => _passengerForm(index),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitBooking,
        label: const Text('Confirm Booking'),
        icon: const Icon(Icons.check),
      ),
    );
  }

  Widget _passengerForm(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Passenger ${index + 1} (${_passengers[index]['type']})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (value) => value!.isEmpty ? 'Required' : null,
              onSaved: (value) => _passengers[index]['name'] = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Passport Number'),
              validator: (value) => value!.isEmpty ? 'Required' : null,
              onSaved: (value) => _passengers[index]['passportNumber'] = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Phone Number'),
              validator: (value) => value!.isEmpty ? 'Required' : null,
              onSaved: (value) => _passengers[index]['phoneNumber'] = value!,
            ),
          ],
        ),
      ),
    );
  }
}
