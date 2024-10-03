import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingAnimation extends StatelessWidget {
  final double size;
  final String? message;
  
  const LoadingAnimation({
    Key? key,
    this.size = 10,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
          'assets/animations/Animation - 1725341208654.lottie',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}