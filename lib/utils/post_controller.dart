
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:state_change_demo/models/post.model.dart';
import 'package:state_change_demo/utils/http_service.dart';

class PostController with ChangeNotifier {
  Map<String, dynamic> posts = {};
  bool working = true;
  Object? error;

  List<Post> get postList => posts.values.whereType<Post>().toList();

  clear() {
    error = null;
    posts = {};
    notifyListeners();
  }

  Future<Post> makePost(
      {required String title,
      required String body,
      required int userId}) async {
    try {
      working = true;
      if (error != null) error = null;
      http.Response res = await HttpService.post(
          url: "https://jsonplaceholder.typicode.com/posts",
          body: {"title": title, "body": body, "userId": userId});
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }

      Map<String, dynamic> result = jsonDecode(res.body);

      Post output = Post.fromJson(result);
      posts[output.id.toString()] = output;
      working = false;
      notifyListeners();
      return output;
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
      return Post.empty;
    }
  }

  Future<void> getPosts() async {
    try {
      working = true;
      clear();
      http.Response res = await HttpService.get(
          url: "https://jsonplaceholder.typicode.com/posts");
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }
      List<dynamic> result = jsonDecode(res.body);
      posts = {
        for (var p in result) "${Post.fromJson(p).id}": Post.fromJson(p)
      };
      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }

  Future<void> updatePost(
      {required int id,
      required String title,
      required String body,
      required int userId}) async {
    try {
      working = true;
      if (error != null) error = null;
      http.Response res = await HttpService.put(
          url: "https://jsonplaceholder.typicode.com/posts/$id",
          body: {"id": id, "title": title, "body": body, "userId": userId});
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }

      Map<String, dynamic> result = jsonDecode(res.body);

      Post output = Post.fromJson(result);
      posts[output.id.toString()] = output;
      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }

  Future<void> deletePost(int id) async {
    try {
      working = true;
      if (error != null) error = null;
      http.Response res = await HttpService.delete(
          url: "https://jsonplaceholder.typicode.com/posts/$id");
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }

      posts.remove(id.toString());
      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }
}
