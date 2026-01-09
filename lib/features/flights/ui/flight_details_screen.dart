import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:travel_planner/core/theme.dart';
import 'package:travel_planner/models/flight.dart';

class FlightDetailsScreen extends StatelessWidget {
  final Flight flight;

  const FlightDetailsScreen({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: const Text('Flight Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Airline & Price Card
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Airline',
                                style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                flight.airline,
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              '${flight.amount} ${flight.currency}',
                              style: const TextStyle(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Route Visualizer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildEndpoint(flight.departureCode, flight.departureTime, CrossAxisAlignment.start),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  flight.duration,
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      height: 1,
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    Transform.rotate(
                                      angle: 1.57,
                                      child: const Icon(Icons.flight, color: AppTheme.accentColor, size: 24),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _buildEndpoint(flight.arrivalCode, flight.arrivalTime, CrossAxisAlignment.end),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Generated Description Section
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  'About this Flight',
                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _generateDescription(),
                        style: const TextStyle(color: AppTheme.textSecondary, height: 1.6, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.luggage, 'Baggage', '1 Carry-on included'),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.restaurant, 'In-flight Meal', 'Standard Meal Serving'),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.wifi, 'Wi-Fi', 'Available for purchase'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FadeInUp(
        delay: const Duration(milliseconds: 600),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking flow coming soon! 🚀'),
                  backgroundColor: AppTheme.accentColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'Select This Flight',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEndpoint(String code, DateTime time, CrossAxisAlignment align) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          code,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('MMM d').format(time),
          style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
        ),
        Text(
          DateFormat('HH:mm').format(time),
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentColor, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _generateDescription() {
    return 'Experience a seamless journey with ${flight.airline} from ${flight.departureCode} to ${flight.arrivalCode}. '
           'This flight offers a total travel time of ${flight.duration}. '
           'Enjoy ${flight.airline}\'s renowned service and comfort as you travel to your destination.';
  }
}
