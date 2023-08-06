import 'dart:async';
import 'dart:convert';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:bloc_demo/bloc/post.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:stream_transform/stream_transform.dart';

part './post_event.dart';

part './post_state.dart';

typedef HttpClient = http.Client;

const _postLimit = 30;

const _postDuration = Duration(milliseconds: 100);

EventTransformer<T> postDroppable<T>(Duration duration) {
  return (events, mapper) {
    return droppable<T>().call(events.throttle(duration), mapper);
  };
}

class PostBloc extends Bloc<PostEvent, PostState> {
  final HttpClient _client;

  PostBloc({required HttpClient client})
      : _client = client,
        super(
          const PostState(),
        ) {
    on<PostFetched>(_onPostFetched, transformer: postDroppable(_postDuration));
  }

  Future<void> _onPostFetched(PostFetched event, Emitter<PostState> emit) async {
    if (state.hasReachedMax) return;

    try {
      if (state.status == PostStatus.initial) {
        final posts = await _fetchPosts();
        return emit(
          state.copyWith(status: PostStatus.success, posts: posts, hasReachedMax: false),
        );
      }
      final newPosts = await _fetchPosts(state.posts.length);
      newPosts.isEmpty
          ? emit(
              state.copyWith(hasReachedMax: true),
            )
          : emit(
              state.copyWith(
                status: PostStatus.success,
                posts: List.of(state.posts)..addAll(newPosts),
                hasReachedMax: false,
              ),
            );
    } catch (_) {
      emit(state.copyWith(status: PostStatus.failure));
    }
  }

  Future<List<Post>> _fetchPosts([int startIndex = 0]) async {
    final response = await _client.get(
      Uri.https(
        //https://jsonplaceholder.typicode.com/posts?start=2&_limit=10
        'jsonplaceholder.typicode.com',
        '/posts',
        {'_start': '$startIndex', '_limit': '$_postLimit'},
      ),
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
