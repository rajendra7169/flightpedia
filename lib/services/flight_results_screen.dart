import 'package:flutter/material.dart';
import 'passenger_details_screen.dart';

class FlightResultsScreen extends StatelessWidget {
  final String departureCity;
  final String arrivalCity;
  final int adults;
  final int children;
  final DateTime departureDate;

  const FlightResultsScreen({
    super.key,
    required this.departureCity,
    required this.arrivalCity,
    required this.adults,
    required this.children,
    required this.departureDate,
    required List<Map<String, dynamic>> flights,
  });

  @override
  Widget build(BuildContext context) {
    // Updated list of dynamic flight data for different countries
    final List<Map<String, dynamic>> allFlights = [
      // Nepal to India
      {
        'airline': 'Yeti Airlines',
        'flightNumber': 'YT-701',
        'departureCity': 'KTM',
        'arrivalCity': 'DEL',
        'departureTime': '10:00 AM',
        'arrivalTime': '12:30 PM',
        'price': 15000.00,
      },
      {
        'airline': 'Buddha Air',
        'flightNumber': 'BA-205',
        'departureCity': 'KTM',
        'arrivalCity': 'DEL',
        'departureTime': '12:00 PM',
        'arrivalTime': '2:30 PM',
        'price': 14000.00,
      },
      {
        'airline': 'Air India',
        'flightNumber': 'AI-101',
        'departureCity': 'KTM',
        'arrivalCity': 'BOM',
        'departureTime': '6:00 PM',
        'arrivalTime': '9:30 PM',
        'price': 18000.00,
      },

      // Nepal to Australia
      {
        'airline': 'Nepal Airlines',
        'flightNumber': 'NA-302',
        'departureCity': 'KTM',
        'arrivalCity': 'SYD',
        'departureTime': '5:00 AM',
        'arrivalTime': '5:00 PM',
        'price': 75000.00,
      },
      {
        'airline': 'Qantas',
        'flightNumber': 'QF-802',
        'departureCity': 'KTM',
        'arrivalCity': 'MEL',
        'departureTime': '9:00 AM',
        'arrivalTime': '10:00 PM',
        'price': 78000.00,
      },

      // India to USA
      {
        'airline': 'United Airlines',
        'flightNumber': 'UA-505',
        'departureCity': 'DEL',
        'arrivalCity': 'JFK',
        'departureTime': '3:00 AM',
        'arrivalTime': '5:00 PM',
        'price': 120000.00,
      },
      {
        'airline': 'Air India',
        'flightNumber': 'AI-202',
        'departureCity': 'BOM',
        'arrivalCity': 'LAX',
        'departureTime': '6:30 PM',
        'arrivalTime': '9:30 AM',
        'price': 115000.00,
      },

      // UK to Canada
      {
        'airline': 'British Airways',
        'flightNumber': 'BA-909',
        'departureCity': 'LHR',
        'arrivalCity': 'YYZ',
        'departureTime': '10:00 AM',
        'arrivalTime': '1:00 PM',
        'price': 95000.00,
      },
      {
        'airline': 'Air Canada',
        'flightNumber': 'AC-309',
        'departureCity': 'LHR',
        'arrivalCity': 'YVR',
        'departureTime': '8:00 AM',
        'arrivalTime': '11:30 AM',
        'price': 97000.00,
      },

      // Australia to Japan
      {
        'airline': 'Japan Airlines',
        'flightNumber': 'JL-705',
        'departureCity': 'SYD',
        'arrivalCity': 'NRT',
        'departureTime': '7:00 AM',
        'arrivalTime': '3:00 PM',
        'price': 85000.00,
      },
      {
        'airline': 'Qantas',
        'flightNumber': 'QF-601',
        'departureCity': 'MEL',
        'arrivalCity': 'HND',
        'departureTime': '11:00 PM',
        'arrivalTime': '7:30 AM',
        'price': 86000.00,
      },
    ];

    // Filter flights based on user input
    final filteredFlights = allFlights
        .where((flight) =>
            flight['departureCity'] == departureCity &&
            flight['arrivalCity'] == arrivalCity)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$departureCity to $arrivalCity'),
            Text(
              '${departureDate.day}/${departureDate.month}/${departureDate.year}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: filteredFlights.isEmpty
            ? const Center(
                child: Text(
                  'No flights available for this route',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
            : ListView.builder(
                itemCount: filteredFlights.length,
                itemBuilder: (context, index) {
                  final flight = filteredFlights[index];
                  final totalPrice =
                      (flight['price'] as double) * (adults + children);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    flight['airline'] as String,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(flight['flightNumber'] as String),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'NPR $totalPrice',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('${adults + children} Passenger(s)'),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(flight['departureTime'] as String),
                                  Text(departureCity),
                                ],
                              ),
                              const Icon(Icons.airplanemode_active,
                                  color: Colors.blue),
                              Column(
                                children: [
                                  Text(flight['arrivalTime'] as String),
                                  Text(arrivalCity),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PassengerDetailsScreen(
                                    flight: flight,
                                    totalPassengers: adults + children,
                                    adults: adults,
                                    children: children,
                                    totalPrice: totalPrice,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              minimumSize: const Size(double.infinity, 40),
                            ),
                            child: const Text('Book Now',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
