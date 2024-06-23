import 'package:flutter/material.dart';
import 'package:state_change_demo/models/post.model.dart';
import 'package:state_change_demo/src/screens/rest_demo.dart';
import 'package:state_change_demo/utils/post_controller.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final PostController controller;

  const PostCard({super.key, 
    required this.post,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(post.body),
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditPostDialog(
                          controller: controller,
                          post: post,
                        ),
                      ),
                    );
                  },
                  child: const Text("Edit"),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDeleteConfirmationDialog(context, post.id);
                  },
                  child: const Icon(Icons.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showDeleteConfirmationDialog(BuildContext context, int postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Post"),
          content: const Text("Are you sure you want to delete this post?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await controller.deletePost(postId);
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}