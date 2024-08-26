import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class AnimationViewModel extends ChangeNotifier {
  AnimationController? waveAnimationController;
  AnimationController? turtleAnimationController;
  Uint8List? gifBytes;
  Uint8List? gifBytes2;
  

  AnimationViewModel(TickerProvider vsync) {
    waveAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: vsync,
    )..repeat(reverse: true);

    turtleAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: vsync,
    )..repeat();

    _loadGif();
    _loadGif2();
  }

  Future<void> _loadGif() async {
    try {
      final ByteData data = await rootBundle.load('assets/gif/turtle.gif');
      gifBytes2 = data.buffer.asUint8List();
      notifyListeners();
    } catch (e) {
      print('Error loading GIF: $e');
    }
  }

  Future<void> _loadGif2() async {
    try {
      final ByteData data2 = await rootBundle.load('assets/gif/bottle.gif');
      gifBytes = data2.buffer.asUint8List();
      notifyListeners();
    } catch (e) {
      print('Error loading GIF: $e');
    }
  }

  @override
  void dispose() {
    waveAnimationController?.dispose();
    turtleAnimationController?.dispose();
    super.dispose();
  }
}
