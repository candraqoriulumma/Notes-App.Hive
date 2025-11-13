part of 'notes_list_bloc.dart';

abstract class NotesListState extends Equatable {
  const NotesListState();

  @override
  List<Object?> get props => [];
}

class NotesListLoading extends NotesListState {}

class NotesListLoaded extends NotesListState {
  final List<Note> notes;

  const NotesListLoaded(this.notes);

  @override
  List<Object?> get props => [notes];
}
