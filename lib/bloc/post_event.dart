part of './post_bloc.dart';

@immutable
abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

@immutable
class PostFetched extends PostEvent {
  const PostFetched();
}
