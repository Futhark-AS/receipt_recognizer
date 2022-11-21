// Login page
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';



// Class MyLoginPage
class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key});

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final TextEditingController _controller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton.extended(
              heroTag: 'login',
              onPressed: () async {
                // Navigate to the second screen using a named route.
                await FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());
                Navigator.pushReplacementNamed(context, '/');
              },
              label: const Text('Sign In with Google'),
              icon: const Icon(Icons.security),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

