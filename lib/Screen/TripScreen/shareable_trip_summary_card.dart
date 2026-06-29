import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Model/trip_model.dart';
import 'package:splitter/Services/shareable_card_service.dart';

/// A premium shareable trip summary card with dark gradient and stats.
/// Wrapped in [RepaintBoundary] for image capture and sharing.
class ShareableTripSummaryCard extends StatelessWidget {
  final TripModel trip;
  final TripSummaryStats summary;
  final GlobalKey repaintKey;

  const ShareableTripSummaryCard({
    required this.trip,
    required this.summary,
    required this.repaintKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Capturable Card ──
        RepaintBoundary(
          key: repaintKey,
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F3460),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: neopopAccent.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: neopopAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.flight_takeoff_rounded,
                        color: neopopAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.tripName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (trip.destination != null)
                            Text(
                              '📍 ${trip.destination}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // ── Date Range ──
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${dateFormat.format(trip.startDate)} – ${dateFormat.format(trip.endDate)}, ${trip.endDate.year}  •  ${trip.totalDays} days',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Total Spent Hero ──
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Total Spent',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${summary.totalSpent.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Stats Grid ──
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _statTile(
                              '📊',
                              'Per Day',
                              '₹${summary.avgPerDay.toStringAsFixed(0)}',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: Colors.white.withOpacity(0.08),
                          ),
                          Expanded(
                            child: _statTile(
                              '🧾',
                              'Transactions',
                              '${summary.totalTransactions}',
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.white.withOpacity(0.06),
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _statTile(
                              '🏆',
                              'MVP',
                              summary.mvpMemberName,
                              subtitle:
                                  '₹${summary.mvpAmount.toStringAsFixed(0)}',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: Colors.white.withOpacity(0.08),
                          ),
                          Expanded(
                            child: _statTile(
                              '📂',
                              'Top Category',
                              summary.topCategory,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Biggest Expense ──
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: neopopYellow.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: neopopYellow.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('💰', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Biggest Expense',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              summary.biggestExpenseDesc,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${summary.biggestExpenseAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: neopopYellow,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── Branding ──
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: neopopAccent.withOpacity(0.5), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'SplitO',
                        style: TextStyle(
                          color: neopopAccent.withOpacity(0.5),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Share Button (outside boundary) ──
        SizedBox(
          width: 200,
          child: ElevatedButton.icon(
            onPressed: () => ShareableCardService.captureAndShare(
              repaintKey,
              filename:
                  'splito_trip_${trip.tripName.replaceAll(' ', '_').toLowerCase()}',
              shareText:
                  '${trip.tripName} — ₹${summary.totalSpent.toStringAsFixed(0)} spent over ${trip.totalDays} days! Shared via SplitO ✨',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: neopopAccent,
              foregroundColor: neopopBackground,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text(
              'Share Trip',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statTile(String emoji, String label, String value,
      {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}
