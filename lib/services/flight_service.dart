class FlightService {
  // Hardcoded flight data
  Future<List<Map<String, dynamic>>> fetchFlights({
    required String departureIata,
    required String arrivalIata,
  }) async {
    try {
      return [
        {
          'airline': 'Yeti Airlines',
          'flightNumber': 'YT-701',
          'departureCity': 'KTM',
          'arrivalCity': 'DEL',
          'departureTime': '10:00 AM',
          'arrivalTime': '12:30 PM',
          'price': 15000.00
        }
      ];
    } catch (e) {
      return [];
    }
  }

  // Fetch airports for search
  static Future<List<Map<String, dynamic>>> fetchAirports(String query) async {
    final airports = [
      // Nepal
      {
        "iata": "KTM",
        "name": "Tribhuvan International Airport",
        "city": "Kathmandu"
      },
      {
        "iata": "BHR",
        "name": "Gautam Buddha International Airport",
        "city": "Bhairahawa"
      },
      {
        "iata": "PKR",
        "name": "Pokhara International Airport",
        "city": "Pokhara"
      },

      // India
      {
        "iata": "DEL",
        "name": "Indira Gandhi International Airport",
        "city": "Delhi"
      },
      {
        "iata": "BOM",
        "name": "Chhatrapati Shivaji Maharaj International Airport",
        "city": "Mumbai"
      },
      {
        "iata": "MAA",
        "name": "Chennai International Airport",
        "city": "Chennai"
      },
      {
        "iata": "BLR",
        "name": "Kempegowda International Airport",
        "city": "Bangalore"
      },
      {
        "iata": "HYD",
        "name": "Rajiv Gandhi International Airport",
        "city": "Hyderabad"
      },
      {
        "iata": "CCU",
        "name": "Netaji Subhas Chandra Bose International Airport",
        "city": "Kolkata"
      },
      {
        "iata": "AMD",
        "name": "Sardar Vallabhbhai Patel International Airport",
        "city": "Ahmedabad"
      },

      // Australia
      {
        "iata": "SYD",
        "name": "Sydney Kingsford Smith International Airport",
        "city": "Sydney"
      },
      {"iata": "MEL", "name": "Melbourne Airport", "city": "Melbourne"},
      {"iata": "BNE", "name": "Brisbane Airport", "city": "Brisbane"},
      {"iata": "PER", "name": "Perth Airport", "city": "Perth"},
      {"iata": "ADL", "name": "Adelaide Airport", "city": "Adelaide"},
      {"iata": "CBR", "name": "Canberra Airport", "city": "Canberra"},

      // United States
      {
        "iata": "JFK",
        "name": "John F. Kennedy International Airport",
        "city": "New York"
      },
      {
        "iata": "LAX",
        "name": "Los Angeles International Airport",
        "city": "Los Angeles"
      },
      {
        "iata": "ORD",
        "name": "O'Hare International Airport",
        "city": "Chicago"
      },
      {
        "iata": "ATL",
        "name": "Hartsfield-Jackson Atlanta International Airport",
        "city": "Atlanta"
      },
      {
        "iata": "DFW",
        "name": "Dallas/Fort Worth International Airport",
        "city": "Dallas"
      },
      {
        "iata": "SFO",
        "name": "San Francisco International Airport",
        "city": "San Francisco"
      },

      // United Kingdom
      {"iata": "LHR", "name": "London Heathrow Airport", "city": "London"},
      {"iata": "LGW", "name": "Gatwick Airport", "city": "London"},
      {"iata": "MAN", "name": "Manchester Airport", "city": "Manchester"},
      {"iata": "EDI", "name": "Edinburgh Airport", "city": "Edinburgh"},
      {"iata": "BHX", "name": "Birmingham Airport", "city": "Birmingham"},

      // Canada
      {
        "iata": "YYZ",
        "name": "Toronto Pearson International Airport",
        "city": "Toronto"
      },
      {
        "iata": "YVR",
        "name": "Vancouver International Airport",
        "city": "Vancouver"
      },
      {
        "iata": "YUL",
        "name": "Montréal-Pierre Elliott Trudeau International Airport",
        "city": "Montreal"
      },
      {
        "iata": "YYC",
        "name": "Calgary International Airport",
        "city": "Calgary"
      },
      {
        "iata": "YEG",
        "name": "Edmonton International Airport",
        "city": "Edmonton"
      },

      // China
      {
        "iata": "PEK",
        "name": "Beijing Capital International Airport",
        "city": "Beijing"
      },
      {
        "iata": "PVG",
        "name": "Shanghai Pudong International Airport",
        "city": "Shanghai"
      },
      {
        "iata": "CAN",
        "name": "Guangzhou Baiyun International Airport",
        "city": "Guangzhou"
      },
      {
        "iata": "SZX",
        "name": "Shenzhen Bao'an International Airport",
        "city": "Shenzhen"
      },
      {
        "iata": "HKG",
        "name": "Hong Kong International Airport",
        "city": "Hong Kong"
      },

      // Germany
      {"iata": "FRA", "name": "Frankfurt Airport", "city": "Frankfurt"},
      {"iata": "MUC", "name": "Munich Airport", "city": "Munich"},
      {"iata": "BER", "name": "Berlin Brandenburg Airport", "city": "Berlin"},
      {"iata": "DUS", "name": "Düsseldorf Airport", "city": "Düsseldorf"},
      {"iata": "HAM", "name": "Hamburg Airport", "city": "Hamburg"},

      // France
      {"iata": "CDG", "name": "Charles de Gaulle Airport", "city": "Paris"},
      {"iata": "ORY", "name": "Orly Airport", "city": "Paris"},
      {"iata": "NCE", "name": "Nice Côte d'Azur Airport", "city": "Nice"},
      {"iata": "LYS", "name": "Lyon-Saint Exupéry Airport", "city": "Lyon"},
      {
        "iata": "MRS",
        "name": "Marseille Provence Airport",
        "city": "Marseille"
      },

      // Japan
      {"iata": "NRT", "name": "Narita International Airport", "city": "Tokyo"},
      {"iata": "HND", "name": "Tokyo Haneda Airport", "city": "Tokyo"},
      {"iata": "KIX", "name": "Kansai International Airport", "city": "Osaka"},
      {"iata": "ITM", "name": "Osaka International Airport", "city": "Osaka"},
      {"iata": "CTS", "name": "New Chitose Airport", "city": "Sapporo"}
    ];

    return airports
        .where((a) =>
            a['city']!.toLowerCase().contains(query.toLowerCase()) ||
            a['iata']!.toLowerCase().contains(query.toLowerCase()))
        .map((a) => {
              'iata_code': a['iata'],
              'airport_name': a['name'],
              'city_name': a['city']
            })
        .toList();
  }
}
