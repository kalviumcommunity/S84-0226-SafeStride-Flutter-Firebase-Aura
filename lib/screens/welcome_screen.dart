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
      debugPrint('Button pressed. isClicked = $isClicked');
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
                  ? 'Hot Reload Successful 🚀'
                  : 'Welcome to Flutter DevTools Demo',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: isClicked ? 'Reset' : 'Click Me',
              onPressed: toggleState,
            ),
          ],
        ),
      ),
    );
  }
}