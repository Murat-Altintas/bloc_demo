import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:bloc_demo/bloc/post.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

part './post_event.dart';

part './post_state.dart';

typedef HttpClient = http.Client;

const _postLimit = 20;

class PostBloc extends Bloc<PostEvent, PostState> {
  final HttpClient _client;

  PostBloc({required HttpClient client})
      : _client = client,
        super(
          const PostState(),
        ) {
    on<PostFetched>(_onPostFetched);
  }

  Future<void> _onPostFetched(PostFetched event, Emitter<PostState> emit) async {
    if (state.hasReachedMax) return;
    if (state.status == PostStatus.initial) {
      final posts = await _fetchPosts();
      return emit(
        state.copyWith(status: PostStatus.success, posts: posts, hasReachedMax: false),
      );
    }
  }

  Future<List<Post>> _fetchPosts([int startIndex = 0]) async {
    final response = await _client.get(
      Uri.https('jsonplaceholder.typicode.com', '/posts', {'_start': '$startIndex', '_limit': '$_postLimit'}),
    );
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List<dynamic>).map((dynamic post) => Post.fromJson(JsonMap.from(post))).cast<Post>().toList();
    }
    throw PostException(error: response.body);
  }
}

class PostException implements Exception {
  final String error;

  PostException({required this.error});
}
