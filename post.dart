// pubspec.yaml -> dependencies:
//   http: ^1.2.0
//
// POST API example using https://jsonplaceholder.typicode.com/posts

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ---------- 1. MODEL ----------
class Post {
  final int? id; // null before the server creates it
  final int userId;
  final String title;
  final String body;

  Post({
    this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'title': title,
        'body': body,
      };
}

// ---------- 2. API SERVICE ----------
class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<Post> createPost(Post post) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/posts'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(post.toJson()), // model -> JSON string
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body)); // 201 = Created
    } else {
      throw Exception('Failed to create post (${response.statusCode})');
    }
  }
}

// ---------- 3. UI ----------
void main() => runApp(const MaterialApp(home: CreatePostScreen()));

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isLoading = false;
  String _result = '';

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final newPost = Post(
        userId: 1,
        title: _titleController.text,
        body: _bodyController.text,
      );
      final created = await ApiService().createPost(newPost);
      setState(() => _result = 'Created! ID: ${created.id}');
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POST API - Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Body',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Submit'),
                    ),
                  ),
            const SizedBox(height: 16),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
