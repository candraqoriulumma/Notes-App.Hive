import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/note.dart';
import '../repositories/notes_repository.dart';

part 'notes_list_event.dart';
part 'notes_list_state.dart';

class NotesListBloc extends Bloc<NotesListEvent, NotesListState> {
  final NotesRepository repository;

  NotesListBloc({required this.repository}) : super(NotesListLoading()) {
    // ✅ Load semua catatan
    on<LoadNotes>(_onLoadNotes);

    // ✅ Refresh daftar catatan
    on<RefreshNotes>(_onRefreshNotes);

    // ✅ Hapus catatan
    on<DeleteNoteEvent>(_onDeleteNote);
  }

  Future<void> _onLoadNotes(
    LoadNotes event,
    Emitter<NotesListState> emit,
  ) async {
    emit(NotesListLoading());
    final notes = await repository.getAllNotes();
    emit(NotesListLoaded(notes));
  }

  Future<void> _onRefreshNotes(
    RefreshNotes event,
    Emitter<NotesListState> emit,
  ) async {
    final notes = await repository.getAllNotes();
    emit(NotesListLoaded(notes));
  }

  Future<void> _onDeleteNote(
    DeleteNoteEvent event,
    Emitter<NotesListState> emit,
  ) async {
    await repository.deleteNote(event.id);
    final notes = await repository.getAllNotes();
    emit(NotesListLoaded(notes));
  }
}
