import 'package:bloc/bloc.dart';
import '../models/note.dart';
import '../repositories/notes_repository.dart';

class NoteFormState {
  final Note note;
  final bool saving;
  final String? error;

  const NoteFormState({
    required this.note,
    this.saving = false,
    this.error,
  });

  NoteFormState copyWith({
    Note? note,
    bool? saving,
    String? error,
    bool clearError = false,
  }) {
    return NoteFormState(
      note: note ?? this.note,
      saving: saving ?? this.saving,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class NoteFormCubit extends Cubit<NoteFormState> {
  final NotesRepository repository;

  NoteFormCubit({required this.repository})
      : super(NoteFormState(
            note: Note(title: '', content: '', createdAt: DateTime.now())));

  /// Load note saat mode edit
  void load(Note note) {
    emit(state.copyWith(note: note, clearError: true));
  }

  /// Update judul dan hapus error sebelumnya
  void updateTitle(String t) {
    emit(state.copyWith(
      note: state.note.copyWith(title: t),
      clearError: true,
    ));
  }

  /// Update isi dan hapus error sebelumnya
  void updateContent(String c) {
    emit(state.copyWith(
      note: state.note.copyWith(content: c),
      clearError: true,
    ));
  }

  /// Simpan catatan baru atau edit yang lama
  Future<void> save() async {
    // Cegah klik simpan berulang
    if (state.saving) return;

    final title = state.note.title.trim();
    final content = state.note.content.trim();

    // Validasi input kosong
    if (title.isEmpty && content.isEmpty) {
      emit(state.copyWith(error: 'Judul dan isi catatan tidak boleh kosong.'));
      return;
    }

    emit(state.copyWith(saving: true, clearError: true));

    try {
      final isEditing = state.note.id != null;
      final noteToSave = state.note.copyWith(
        createdAt: isEditing ? state.note.createdAt : DateTime.now(),
      );

      final savedNote = await repository.saveNote(noteToSave);
      emit(state.copyWith(note: savedNote, saving: false));
    } catch (e) {
      emit(state.copyWith(
        saving: false,
        error: 'Gagal menyimpan catatan: ${e.toString()}',
      ));
    }
  }
}
