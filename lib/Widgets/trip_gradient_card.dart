import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Model/trip_model.dart';
import 'package:intl/intl.dart';

class TripGradientCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;

  const TripGradientCard({
    super.key,
    required this.trip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = _getTripGradient(trip.tripName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.last.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    for (int i = 0;
                        i < (trip.memberIds.length.clamp(0, 2));
                        i++)
                      Align(
                        widthFactor: 0.6,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white24,
                          child:
                              Icon(Icons.person, size: 14, color: Colors.white),
                        ),
                      ),
                    if (trip.memberIds.length > 2)
                      Align(
                        widthFactor: 0.6,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: neopopBackground.withOpacity(0.5),
                          child: Text(
                            "+${trip.memberIds.length - 2}",
                            style: const TextStyle(
                                fontSize: 8, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                Icon(
                  _getTripIcon(trip.tripName),
                  color: Colors.white.withOpacity(0.5),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "${DateFormat('d MMM').format(trip.startDate)} - ${DateFormat('d MMM').format(trip.endDate)}",
                    style: const TextStyle(fontSize: 8, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  trip.tripName,
                  style: sub_headline5_text.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Albra',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getTripGradient(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains("goa")) {
      return const LinearGradient(
        colors: [Color(0xFF5C54DB), Color(0xFF4A40BF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (lowerName.contains("bali")) {
      return const LinearGradient(
        colors: [Color(0xFFF25C30), Color(0xFFD94A1E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF6C63FF), Color(0xFF483D8B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  IconData _getTripIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains("goa") || lowerName.contains("flight"))
      return Icons.flight_takeoff_rounded;
    if (lowerName.contains("beach") || lowerName.contains("bali"))
      return Icons.beach_access_rounded;
    return Icons.explore_rounded;
  }
}
