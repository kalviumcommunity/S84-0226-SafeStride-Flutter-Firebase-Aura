import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isClicked = false;

  void toggleState() {
    setState(() {
      isClicked = !isClicked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Safe'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isClicked
                  ? 'Ready to explore safe routes!'
                  : 'Welcome to Route Safe 🚴',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Icon(
              Icons.directions_bike,
              size: 100,
              color: isClicked ? Colors.green : Colors.blue,
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'Get Started',
              onPressed: toggleState,
            ),
          ],
        ),
      ),
    );
  }
}