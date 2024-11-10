import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterTutorialPopup extends StatefulWidget {
  final VoidCallback onComplete;

  const WaterTutorialPopup({
    super.key,
    required this.onComplete,
  });

  @override
  State<WaterTutorialPopup> createState() => _WaterTutorialPopupState();
}

class _WaterTutorialPopupState extends State<WaterTutorialPopup> {
  final PageController _pageController = PageController();
  bool _doNotShowAgain = false;
  int _currentPage = 0;

  final List<TutorialStep> _tutorialSteps = [
    TutorialStep(
      image: 'assets/images/clearPhoto.png',
      title: 'Take a Clear Photo',
      description:
          'Position your device camera directly above the water sample.',
      highlightedText:
          'Use camera flashlight when taking a photo.\nMake sure there isn\'t any reflection!',
    ),
    TutorialStep(
      image: 'assets/images/waterAnalyze.png',
      title: 'Analyze Water',
      description:
          'Our AI will analyze the water clarity and provide NTU measurements.',
      highlightedText: '',
    ),
    TutorialStep(
      image: 'assets/images/waterCheck.png',
      title: 'View Results',
      description:
          'Get detailed results about water clarity and recommendations.',
      highlightedText: '',
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
            colors: [Color(0xFF0083AB), Color(0xFF003545)],
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 160, // Reduced from 180
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
            const SizedBox(height: 16), // Reduced from 24
            Text(
              step.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'RobotoCondensed',
              ),
            ),
            const SizedBox(height: 12), // Reduced from 16
            Text(
              step.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                fontFamily: 'RobotoCondensed',
              ),
            ),
            if (step.highlightedText.isNotEmpty) ...[
              const SizedBox(height: 12), // Reduced from 16
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10), // Reduced vertical padding
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.cyan.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step.highlightedText,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.3, // Reduced from 1.4
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8), // Added bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.only(bottom: 8), // Added padding
      child: Row(
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
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), // Adjusted padding
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 8), // Reduced from 10
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
  final String highlightedText;

  TutorialStep({
    required this.image,
    required this.title,
    required this.description,
    required this.highlightedText,
  });
}
