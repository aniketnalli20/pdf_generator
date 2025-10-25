import 'package:flutter/material.dart';
// NOTE: For GoogleFonts, add the package and import:
// import 'package:google_fonts/google_fonts.dart'; 
import 'gradient_code.dart';

class SplashScreen extends StatefulWidget {
  // Replace HomeScreen with your main app screen
  final Widget nextScreen; 
  const SplashScreen({super.key, required this.nextScreen});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut, // Using elasticOut for a nicer effect
    );
    
    _animationController.forward();
    _navigateToHome();
  }

  _navigateToHome() async {
    // Delay for a total of 3 seconds
    await Future.delayed(const Duration(milliseconds: 3000)); 
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => widget.nextScreen),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor removed in favor of gradient container
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated App Logo Container
              ScaleTransition(
                scale: _animation,
                child: Container(
                  width: 96.0,
                  height: 96.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24), // Smoother corners
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.flutter_dash,
                    size: 72.0,
                    color: Color(0xFF3C52CD),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // App Name Text
              FadeTransition(
                opacity: _animation,
                child: Text(
                  'My Flutter App',
                  style: const TextStyle( // Using const for better performance
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
                          // Progress Indicator
              FadeTransition(
                opacity: _animation,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}