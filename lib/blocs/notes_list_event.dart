part of 'notes_list_bloc.dart';

abstract class NotesListEvent extends Equatable {
  const NotesListEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotes extends NotesListEvent {}

class RefreshNotes extends NotesListEvent {}

class DeleteNoteEvent extends NotesListEvent {
  final int id;
  const DeleteNoteEvent(this.id);
  @override
  List<Object?> get props => [id];
}
