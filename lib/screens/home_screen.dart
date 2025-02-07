import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flightpedia/services/flight_results_screen.dart';
import '../services/flight_service.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOneWay = true;
  String? _departureCity;
  String? _arrivalCity;
  DateTime? _departureDate;
  DateTime? _returnDate;
  int _adults = 1;
  int _children = 0;
  final FlightService _flightService = FlightService();
  List<Map<String, dynamic>> _departureAirports = [];
  List<Map<String, dynamic>> _arrivalAirports = [];
  bool _isLoading = false;
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();

  @override
  void dispose() {
    _departureController.dispose();
    _arrivalController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  Future<void> _searchAirports(String query, bool isDeparture) async {
    if (query.isEmpty) {
      setState(() {
        if (isDeparture) {
          _departureAirports = [];
        } else {
          _arrivalAirports = [];
        }
      });
      return;
    }

    try {
      final airports = await FlightService.fetchAirports(query);
      setState(() {
        if (isDeparture) {
          _departureAirports = airports;
        } else {
          _arrivalAirports = airports;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() {
        if (isDeparture) {
          _departureAirports = [];
        } else {
          _arrivalAirports = [];
        }
      });
    }
  }

  void _incrementCounter(bool isAdult) {
    setState(() {
      if (isAdult) {
        _adults++;
      } else {
        _children++;
      }
    });
  }

  void _decrementCounter(bool isAdult) {
    setState(() {
      if (isAdult && _adults > 0) {
        _adults--;
      } else if (!isAdult && _children > 0) {
        _children--;
      }
    });
  }

  Widget _buildCityField(
    String hint,
    bool isDeparture,
    List<Map<String, dynamic>> airports,
    Function(String) onSearch,
    Function(Map<String, dynamic>) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: isDeparture ? _departureController : _arrivalController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: hint,
            labelStyle: const TextStyle(color: Colors.white70),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            suffixIcon: const Icon(Icons.location_city, color: Colors.white70),
          ),
          onChanged: (value) {
            if (value.length > 2) {
              onSearch(value);
            }
          },
        ),
        if (airports.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: airports.length,
              itemBuilder: (context, index) {
                final airport = airports[index];
                return ListTile(
                  title: Text(
                    airport['airport_name'] ?? 'Unknown Airport',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${airport['city_name']} (${airport['iata_code']})',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    if (isDeparture) {
                      _departureCity = airport['iata_code'];
                      _departureController.text =
                          '${airport['airport_name']} (${airport['iata_code']})';
                    } else {
                      _arrivalCity = airport['iata_code'];
                      _arrivalController.text =
                          '${airport['airport_name']} (${airport['iata_code']})';
                    }
                    onSelect(airport);
                    setState(() => airports.clear());
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          suffixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
        ),
        child: Text(
          date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Select Date',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPassengerSelector(String label, int count, bool isAdult) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label*',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.white),
              onPressed: () => _decrementCounter(isAdult),
            ),
            Text(
              '$count',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _incrementCounter(isAdult),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToDestinationDetail(Map<String, dynamic> destination) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(destination['name'])),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.network(
                        destination['image'],
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              destination['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.grey),
                                Text(
                                  destination['location'],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber),
                                Text(
                                  destination['rating'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              destination['description'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FlightResultsScreen(
                            departureCity: 'KTM',
                            arrivalCity: destination['iata'],
                            adults: 1,
                            children: 0,
                            departureDate: DateTime.now(),
                            flights: [],
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Book Flight Now',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image with Blur
          SizedBox.expand(
            child: Image.network(
              'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
              fit: BoxFit.cover,
            ),
          ),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(
                  'Hi, ${widget.userName}',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                snap: true,
                pinned: false,
                expandedHeight: 0,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Where to fly today?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),

                      // Search Card
                      _buildGlassCard(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('One Way'),
                                  selected: _isOneWay,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _isOneWay = selected;
                                      if (!selected) _returnDate = null;
                                    });
                                  },
                                ),
                                const SizedBox(width: 10),
                                ChoiceChip(
                                  label: const Text('Return'),
                                  selected: !_isOneWay,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _isOneWay = !selected;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildCityField(
                              'Select a departure city',
                              true,
                              _departureAirports,
                              (value) => _searchAirports(value, true),
                              (selected) => setState(
                                  () => _departureCity = selected['iata_code']),
                            ),
                            const SizedBox(height: 15),
                            _buildCityField(
                              'Select a arrival city',
                              false,
                              _arrivalAirports,
                              (value) => _searchAirports(value, false),
                              (selected) => setState(
                                  () => _arrivalCity = selected['iata_code']),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDateField(
                                    'Departure Date',
                                    _departureDate,
                                    () => _selectDate(context, true),
                                  ),
                                ),
                                if (!_isOneWay) const SizedBox(width: 10),
                                if (!_isOneWay)
                                  Expanded(
                                    child: _buildDateField(
                                      'Return Date',
                                      _returnDate,
                                      () => _selectDate(context, false),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                _buildPassengerSelector('Adult', _adults, true),
                                const SizedBox(width: 20),
                                _buildPassengerSelector(
                                    'Child', _children, false),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        if (_departureCity == null ||
                                            _arrivalCity == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Please select both cities'),
                                            ),
                                          );
                                          return;
                                        }

                                        setState(() => _isLoading = true);

                                        try {
                                          final flights =
                                              await _flightService.fetchFlights(
                                            departureIata: _departureCity!,
                                            arrivalIata: _arrivalCity!,
                                          );

                                          if (flights.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'No flights found for selected route'),
                                              ),
                                            );
                                            return;
                                          }

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FlightResultsScreen(
                                                departureCity: _departureCity!,
                                                arrivalCity: _arrivalCity!,
                                                flights: flights,
                                                adults: _adults,
                                                children: _children,
                                                departureDate: _departureDate!,
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Error: ${e.toString()}')),
                                          );
                                        } finally {
                                          setState(() => _isLoading = false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.blue,
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text('Proceed'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                      const Text(
                        'Recommended',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: recommendedDestinations.length,
                          itemBuilder: (context, index) {
                            final dest = recommendedDestinations[index];
                            return _buildDestinationCard(dest);
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Popular This Year',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: newDestinations.length,
                        itemBuilder: (context, index) {
                          final dest = newDestinations[index];
                          return _buildListDestinationCard(dest);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, 0),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Card(
      elevation: 10,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildDestinationCard(Map<String, dynamic> dest) {
    return GestureDetector(
      onTap: () => _navigateToDestinationDetail(dest),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  dest['image'],
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dest['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dest['location'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          dest['rating'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListDestinationCard(Map<String, dynamic> dest) {
    return GestureDetector(
      onTap: () => _navigateToDestinationDetail(dest),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(20)),
                child: Image.network(
                  dest['image'],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dest['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dest['location'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            dest['rating'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(
      BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white.withOpacity(0.1),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.airplane_ticket), label: 'Ticket'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
      ],
      onTap: (index) {
        if (index == 1) {
          Navigator.pushNamed(context, '/ticket');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/history');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/setting');
        }
      },
    );
  }

  final List<Map<String, dynamic>> recommendedDestinations = [
    {
      'name': 'Taj Mahal',
      'location': 'Agra, India',
      'rating': '4.9',
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/6/67/Taj_Mahal_in_India_-_Kristian_Bertel.jpg',
      'description':
          'Iconic white marble mausoleum, a UNESCO World Heritage Site and one of the New Seven Wonders of the World.',
      'iata': 'AGR'
    },
    {
      'name': 'Pashupatinath Temple',
      'location': 'Kathmandu, Nepal',
      'rating': '4.8',
      'image':
          'https://cdn.britannica.com/88/177488-050-080349A3/UNESCO-world-heritage-site-Pashupatinath-Temple-Kathmandu-Nepal.jpg',
      'description':
          'Sacred Hindu temple complex on the banks of the Bagmati River.',
      'iata': 'KTM'
    },
    {
      'name': 'Jaipur City Palace',
      'location': 'Rajasthan, India',
      'rating': '4.7',
      'image':
          'https://lp-cms-production.imgix.net/2019-06/GettyImages-469786746_super.jpg',
      'description':
          'Magnificent royal residence with museums, courtyards, and gardens.',
      'iata': 'JAI'
    },
  ];

  final List<Map<String, dynamic>> newDestinations = [
    {
      'name': 'Lumbini',
      'location': 'Nepal',
      'rating': '4.8',
      'image':
          'https://cdn.elebase.io/173fe953-8a63-4a8a-8ca3-1bacb56d78a5/42b3572f-d69e-49da-82fc-274e221e19fc-garden-gallery-02.jpg?w=1000&h=500&fit=crop&q=75',
      'description':
          'Birthplace of Lord Buddha and UNESCO World Heritage Site.',
      'iata': 'LUM'
    },
    {
      'name': 'Leh-Ladakh',
      'location': 'India',
      'rating': '4.9',
      'image':
          'https://images.nativeplanet.com/img/2017/08/2-18-1503059588.jpg',
      'description':
          'High-altitude desert landscape with stunning mountain views.',
      'iata': 'IXL'
    },
  ];
}
