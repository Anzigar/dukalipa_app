import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class LoadingWidget extends StatelessWidget {
  final double? size;
  final Color? color;

  const LoadingWidget({
    Key? key,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 80.0,
            height: size ?? 80.0,
            child: Lottie.asset(
              'assets/animations/loader2.json',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
