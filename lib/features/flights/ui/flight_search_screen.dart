import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:travel_planner/core/theme.dart';
import 'package:travel_planner/models/flight.dart';
import 'package:travel_planner/services/amadeus_service.dart';
import 'package:travel_planner/features/flights/ui/flight_details_screen.dart';

class FlightSearchScreen extends StatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  final _amadeusService = AmadeusService();
  final _originController = TextEditingController(text: 'TUN');
  final _destinationController = TextEditingController(text: 'CDG');
  final _dateController = TextEditingController(text: '2026-01-10');
  
  List<Flight> _flights = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _searchFlights() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final flights = await _amadeusService.searchFlights(
        origin: _originController.text,
        destination: _destinationController.text,
        date: _dateController.text,
      );
      setState(() {
        _flights = flights;
      });
    } catch (e) {
      // Show actual error for debugging
      final errorMsg = e.toString();
      setState(() {
        if (errorMsg.contains('ClientException')) {
           _error = 'Network Error: Check your connection';
        } else if (errorMsg.contains('Failed to load flight offers')) {
           // Parse the JSON error if possible or show raw
           if (errorMsg.contains('"code"')) { 
             _error = 'Invalid Input. Please use IATA Codes (e.g. JFK, LHR).';
           } else {
             _error = 'API Error: $errorMsg';
           }
        } else {
           _error = 'Error: $errorMsg';
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: const Text('Find Flights', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchForm(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
                : _error != null
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                            child: Text(_error!, 
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 16))),
                      )
                    : _buildFlightList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm() {
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildTextField('Origin (e.g. SYD)', _originController, Icons.flight_takeoff)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Dest (e.g. BKK)', _destinationController, Icons.flight_land)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField('Date (YYYY-MM-DD)', _dateController, Icons.calendar_today),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _searchFlights,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Search Flights', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, color: AppTheme.accentColor, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.accentColor),
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
      ),
    );
  }

  Widget _buildFlightList() {
    if (_flights.isEmpty) {
      return const Center(
        child: Text(
          'Ready to take off? ✈️',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _flights.length,
      itemBuilder: (context, index) {
        final flight = _flights[index];
        return FadeInUp(
          delay: Duration(milliseconds: index * 100),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FlightDetailsScreen(flight: flight),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        flight.airline,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${flight.amount} ${flight.currency}',
                        style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFlightLeg(flight.departureCode, flight.departureTime),
                      const Icon(Icons.flight_takeoff, color: AppTheme.textSecondary, size: 20),
                      Text(flight.duration, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      const Icon(Icons.flight_land, color: AppTheme.textSecondary, size: 20),
                      _buildFlightLeg(flight.arrivalCode, flight.arrivalTime),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlightLeg(String code, DateTime time) {
    return Column(
      children: [
        Text(
          code,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('HH:mm').format(time),
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
