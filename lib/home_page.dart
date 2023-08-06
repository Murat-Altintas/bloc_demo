import 'package:bloc_demo/bloc/post_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/post.dart';
// ignore_for_file: prefer_const_constructors

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostBloc>(
        create: (_) => PostBloc(
              client: HttpClient(),
            )..add(PostFetched()),
        child: HomeView());
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);

  }

  @override
  void dispose() {
    super.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) context.read<PostBloc>().add(PostFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      return currentScroll >= (maxScroll * .9);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Home Page"),
        ),
        body: BlocBuilder<PostBloc, PostState>(
          builder: (context, postState) {
            switch (postState.status) {
              case PostStatus.failure:
                return Center(
                  child: Text("Error"),
                );
              case PostStatus.success:
                if (postState.posts.isEmpty) {
                  return Center(
                    child: Text("Not any post find"),
                  );
                }
                return ListView.builder(
                  itemBuilder: (context, index) {
                    return index >= postState.posts.length ? IndicatorWidget() : ListPostItem(post: postState.posts[index]);
                  },
                  itemCount: postState.hasReachedMax ? postState.posts.length : postState.posts.length + 1,
                  controller: _scrollController,
                );
              default:
                return Center(
                  child: Text("Please wait..."),
                );
            }
          },
        ));
  }
}

class ListPostItem extends StatelessWidget {
  const ListPostItem({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        leading: Text("${post.id}"),
        title: Text(post.title),
        subtitle: Text(post.body),
        isThreeLine: true,
      ),
    );
  }
}

class IndicatorWidget extends StatelessWidget {
  const IndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
        ),
      ),
    );
  }
}
