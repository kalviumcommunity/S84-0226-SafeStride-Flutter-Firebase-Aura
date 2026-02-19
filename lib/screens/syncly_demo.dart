import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SynclyDemo extends StatefulWidget {
  const SynclyDemo({super.key});

  @override
  State<SynclyDemo> createState() => _SynclyDemoState();
}

class _SynclyDemoState extends State<SynclyDemo> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();

  User? _user;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });
  }

  Future<void> _signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _signUp() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed up successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
  }

  Future<void> _addTask() async {
    if (_taskController.text.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('tasks').add({
        'title': _taskController.text.trim(),
        'createdAt': Timestamp.now(),
        'userId': _user?.uid,
        'userEmail': _user?.email,
      });
      _taskController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syncly - Realtime Todo'),
        actions: [
          if (_user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
            )
        ],
      ),
      body: _user == null ? _buildAuthUI() : _buildTodoList(),
    );
  }

  Widget _buildAuthUI() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Welcome to Syncly',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _signIn,
                child: const Text('Sign In'),
              ),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  decoration: const InputDecoration(
                    hintText: 'Enter a new task',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                color: Theme.of(context).primaryColor,
                onPressed: _addTask,
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tasks')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text('No tasks yet. Add one!'));
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final title = data['title'] ?? 'No Title';
                  final userEmail = data['userEmail'] ?? 'Unknown';

                  return ListTile(
                    leading: CircleAvatar(child: Text(userEmail[0].toUpperCase())),
                    title: Text(title),
                    subtitle: Text('Added by $userEmail'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
