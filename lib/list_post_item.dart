
import 'package:flutter/material.dart';

import 'bloc/post.dart';

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