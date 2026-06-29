import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Services/shareable_card_service.dart';

/// A premium glassmorphism card that displays a settlement confirmation.
/// Wrapped in [RepaintBoundary] so it can be captured as an image and shared.
class ShareableSettlementCard extends StatelessWidget {
  final String fromName;
  final String toName;
  final double amount;
  final String groupName;
  final DateTime settledDate;
  final GlobalKey repaintKey;

  const ShareableSettlementCard({
    required this.fromName,
    required this.toName,
    required this.amount,
    required this.groupName,
    required this.settledDate,
    required this.repaintKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Capturable Card ──
        RepaintBoundary(
          key: repaintKey,
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(28),
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
              children: [
                // ── Status Badge ──
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00C853).withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: Color(0xFF00C853), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'SETTLED',
                        style: TextStyle(
                          color: Color(0xFF00C853),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Amount ──
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 20),

                // ── From → To ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      // From
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    neopopAccent.withOpacity(0.8),
                                    neopopAccent.withOpacity(0.4),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _initial(fromName),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              fromName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            const Text(
                              'Paid',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Arrow
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: neopopAccent.withOpacity(0.15),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: neopopAccent,
                          size: 20,
                        ),
                      ),

                      // To
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    neopopYellow.withOpacity(0.8),
                                    neopopYellow.withOpacity(0.4),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _initial(toName),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              toName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            const Text(
                              'Received',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Meta row ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      groupName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy').format(settledDate),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Branding ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        color: neopopAccent.withOpacity(0.6), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'SplitO',
                      style: TextStyle(
                        color: neopopAccent.withOpacity(0.6),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
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
              filename: 'splito_settlement',
              shareText:
                  '$fromName settled ₹${amount.toStringAsFixed(0)} with $toName via SplitO ✨',
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
              'Share',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  String _initial(String name) {
    if (name.isEmpty) return '?';
    return name[0].toUpperCase();
  }
}
