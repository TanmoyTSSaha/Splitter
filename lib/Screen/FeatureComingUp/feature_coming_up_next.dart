import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:splitter/Constants/constants.dart';

class FeatureComingUpNext extends StatefulWidget {
  const FeatureComingUpNext({super.key});

  @override
  State<FeatureComingUpNext> createState() => _FeatureComingUpNextState();
}

class _FeatureComingUpNextState extends State<FeatureComingUpNext> {
  bool _isLightOn = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startLightToggle();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startLightToggle() {
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      setState(() {
        _isLightOn = !_isLightOn;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: neopopBackground,
        body: SizedBox(
          height: devSysHeight,
          width: devSysWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: height_16 * 1.5,
                    height: height_16 * 1.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isLightOn ? neopopYellow : Colors.transparent,
                      boxShadow: _isLightOn
                          ? [
                              const BoxShadow(
                                color: neopopYellow,
                                blurRadius: 40,
                                spreadRadius: 20,
                              ),
                            ]
                          : [],
                    ),
                  ),
                  SvgPicture.asset(
                    "assets/icons/svg/hugeicons--bulb.svg",
                    height: height_16 * 2,
                    width: height_16 * 2,
                    color: neopopOnPrimary,
                  ),
                ],
              ),
              SizedBox(height: height_16),
              Text(
                "This feature is coming up next!\nThank you for your patience :)",
                style: body2_text.copyWith(
                  color: neopopOnPrimary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
