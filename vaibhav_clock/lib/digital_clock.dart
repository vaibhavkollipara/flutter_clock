// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final shadowColor = Colors.grey;
final backgroundColor = Colors.white;

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  bool isRaised = false;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      // _timer = Timer(
      //   Duration(minutes: 1) -
      //       Duration(seconds: _dateTime.second) -
      //       Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      isRaised = !isRaised;
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  String _displayString(String number) {
    return '${(int.parse(number) / 10).floor()} ${(int.parse(number) % 10).floor()}';
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).brightness == Brightness.light
        ? Color.fromRGBO(72, 163, 142, 1)
        : Color.fromRGBO(60, 75, 125, 1);

    final fontSize = MediaQuery.of(context).size.width * 0.25;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);

    return FractionallySizedBox(
        widthFactor: 0.95,
        heightFactor: 0.85,
        child: Container(
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Text(
                '${_displayString(hour)} : ${_displayString(minute)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'SquadaOne-Regular',
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = (fontSize / 10)
                      ..color = backgroundColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold),
              ),
              AnimatedDefaultTextStyle(
                textAlign: TextAlign.center,
                style: isRaised
                    ? TextStyle(
                        fontFamily: 'SquadaOne-Regular',
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                        color: primaryColor)
                    : TextStyle(
                        fontFamily: 'SquadaOne-Regular',
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                        color: primaryColor,
                        shadows: [
                            Shadow(
                              blurRadius: 4.0,
                              color: shadowColor,
                              offset: Offset(4.0, 4.0),
                            )
                          ]),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOutBack,
                child:
                    Text('${_displayString(hour)} : ${_displayString(minute)}'),
              )
            ],
          ),
        ));
  }
}
