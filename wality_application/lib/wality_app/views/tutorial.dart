import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';

class WaterTutorialPage extends StatefulWidget {
  final VoidCallback onComplete;

  const WaterTutorialPage({
    super.key,
    required this.onComplete,
  });

  @override
  State<WaterTutorialPage> createState() => _WaterTutorialPageState();
}

class _WaterTutorialPageState extends State<WaterTutorialPage> {
  final PageController _pageController = PageController();
  bool _doNotShowAgain = false;
  int _currentPage = 0;

  final List<TutorialStep> _tutorialSteps = [
    TutorialStep(
      image: 'assets/images/papercup.jpg',
      title: 'Take a Clear Photo',
      description: 'Position your device camera directly above the water sample.',
    ),
    TutorialStep(
      image: 'assets/images/tutorial_2.png',
      title: 'Analyze Water',
      description: 'Our AI will analyze the water clarity and provide NTU measurements.',
    ),
    TutorialStep(
      image: 'assets/images/tutorial_3.png',
      title: 'View Results',
      description: 'Get detailed results about water clarity and recommendations.',
    ),
  ];

  Future<void> _setTutorialSeen() async {
    if (_doNotShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('water_tutorial_seen', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final popupWidth = size.width * 0.85;
    final popupHeight = size.height * 0.7;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: popupWidth,
        height: popupHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0083AB),Color(0xFF003545)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _tutorialSteps.length,
                itemBuilder: (context, index) {
                  return _buildTutorialPage(_tutorialSteps[index]);
                },
              ),
            ),
            _buildPageIndicator(),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialPage(TutorialStep step) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Image.asset(
              step.image,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'RobotoCondensed',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontFamily: 'RobotoCondensed',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _tutorialSteps.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: _doNotShowAgain,
                onChanged: (value) {
                  setState(() => _doNotShowAgain = value ?? false);
                },
                fillColor: MaterialStateProperty.all(Colors.white),
                checkColor: const Color(0xFF0083AB),
              ),
              const Text(
                'Don\'t show again',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'RobotoCondensed',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              await _setTutorialSeen();
              widget.onComplete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0083AB),
              minimumSize: const Size(200, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Got it!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoCondensed',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class TutorialStep {
  final String image;
  final String title;
  final String description;

  TutorialStep({
    required this.image,
    required this.title,
    required this.description,
  });
}
