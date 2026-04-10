import 'package:crud_app/features/todo/domain/entities/todo.dart';
import 'package:equatable/equatable.dart';

abstract class TodoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> todos;

  TodoLoaded({required this.todos});

  @override
  List<Object?> get props => [todos];
}

class TodoError extends TodoState {
  final String message;

  TodoError({required this.message});

  @override
  List<Object?> get props => [message];
}
