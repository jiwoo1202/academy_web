import 'package:flutter/material.dart';

import 'font/font.dart';

class CountDownComponents extends StatefulWidget {
  final Animation? animation;

  const CountDownComponents({Key? key, this.animation}) : super(key: key);

  @override
  State<CountDownComponents> createState() => _CountDownComponentsState();
}

class _CountDownComponentsState extends State<CountDownComponents>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Countdown extends AnimatedWidget {
  final Animation<int> animation;
  final String? color;
  Countdown({Key? key, required this.animation,this.color})
      : super(key: key, listenable: animation);

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);

    String timerText =
        '${clockTimer.inMinutes.toString().padLeft(2, '0')}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    //'${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    return Text(
      "$timerText",
      style: color=='1'?f50Whitew700:TextStyle(color: Colors.black),
    );
  }
}
