import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:state_change_demo/models/post.model.dart';
import 'package:state_change_demo/utils/post_card.dart';
import 'package:state_change_demo/utils/post_controller.dart';

class RestDemoScreen extends StatefulWidget {
  const RestDemoScreen({super.key});

  @override
  _RestDemoScreenState createState() => _RestDemoScreenState();
}

class _RestDemoScreenState extends State<RestDemoScreen> {
  PostController controller = PostController();
  bool showAllPosts = false;

  @override
  void initState() {
    super.initState();
    controller.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Posts"),
        leading: IconButton(
          onPressed: () {
            controller.getPosts();
          },
          icon: const Icon(Icons.refresh),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showAddEditPostDialog(context);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            if (controller.error != null) {
              return Center(
                child: Text(controller.error.toString()),
              );
            }

            if (!controller.working) {
              if (showAllPosts) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.postList.length,
                  itemBuilder: (context, index) {
                    Post post = controller.postList[index];
                    return PostCard(
                      post: post,
                      controller: controller,
                    );
                  },
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (controller.postList.isNotEmpty)
                        PostCard(
                          post: controller.postList.first,
                          controller: controller,
                        )
                      else
                        const Text("No posts available"),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showAllPosts = true;
                          });
                        },
                        child: Text(
                            "See all posts (${controller.postList.length})"),
                      ),
                    ],
                  ),
                );
              }
            }
            return const Center(
              child: SpinKitChasingDots(
                size: 54,
                color: Colors.black87,
              ),
            );
          },
        ),
      ),
    );
  }

  void showAddEditPostDialog(BuildContext context, {Post? post}) {
    showDialog(
      context: context,
      builder: (dContext) => AddEditPostDialog(
        controller: controller,
        post: post,
      ),
    );
  }
}

class AddEditPostDialog extends StatefulWidget {
  final PostController controller;
  final Post? post;

  const AddEditPostDialog({required this.controller, this.post, super.key});

  @override
  State<AddEditPostDialog> createState() => _AddEditPostDialogState();
}

class _AddEditPostDialogState extends State<AddEditPostDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController bodyC, titleC;
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    bodyC = TextEditingController(text: widget.post?.body ?? '');
    titleC = TextEditingController(text: widget.post?.title ?? '');
    isEdit = widget.post != null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: Text(isEdit ? "Edit Post" : "Add new post"),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (isEdit) {
                await widget.controller.updatePost(
                  id: widget.post!.id,
                  title: titleC.text.trim(),
                  body: bodyC.text.trim(),
                  userId: widget.post!.userId,
                );
              } else {
                await widget.controller.makePost(
                  title: titleC.text.trim(),
                  body: bodyC.text.trim(),
                  userId: 1,
                );
              }
              Navigator.of(context).pop();
            }
          },
          child: Text(isEdit ? "Update" : "Add"),
        )
      ],
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Title"),
            TextFormField(
              controller: titleC,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            const Text("Content"),
            TextFormField(
              controller: bodyC,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter content';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
