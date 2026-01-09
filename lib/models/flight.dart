class Flight {
  final String id;
  final String amount;
  final String currency;
  final String airline;
  final String departureCode;
  final String arrivalCode;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String duration;

  Flight({
    required this.id,
    required this.amount,
    required this.currency,
    required this.airline,
    required this.departureCode,
    required this.arrivalCode,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
  });

  factory Flight.fromMap(Map<String, dynamic> json, Map<String, dynamic>? dictionaries) {
    final price = json['price'];
    final itinerary = json['itineraries'][0];
    final segments = itinerary['segments'];
    final firstSegment = segments.first;
    final lastSegment = segments.last;
    
    final carrierCode = firstSegment['carrierCode'];
    String airlineName = carrierCode;
    
    if (dictionaries != null && dictionaries['carriers'] != null) {
      airlineName = dictionaries['carriers'][carrierCode] ?? carrierCode;
    }

    return Flight(
      id: json['id'],
      amount: price['total'],
      currency: price['currency'],
      airline: airlineName,
      departureCode: firstSegment['departure']['iataCode'],
      arrivalCode: lastSegment['arrival']['iataCode'],
      departureTime: DateTime.parse(firstSegment['departure']['at']),
      arrivalTime: DateTime.parse(lastSegment['arrival']['at']),
      duration: itinerary['duration'].toString().replaceAll('PT', '').toLowerCase(),
    );
  }
}
