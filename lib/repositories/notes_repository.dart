import 'package:hive/hive.dart';
import '../models/note.dart';

class NotesRepository {
  final Box _box;

  NotesRepository(this._box);

  /// 📝 Simpan catatan baru atau perbarui jika sudah ada
  Future<Note> saveNote(Note note) async {
    if (note.id == null) {
      // 🆕 Catatan baru
      final key = await _box.add(note.toMap());
      final newNote = note.copyWith(id: key);
      await _box.put(key, newNote.toMap());
      return newNote;
    } else {
      // ✏️ Sudah ada → update isi
      await _box.put(note.id, note.toMap());
      return note;
    }
  }

  /// ✏️ Update catatan yang sudah ada (fitur edit eksplisit)
  Future<Note?> updateNote(Note updatedNote) async {
    if (updatedNote.id == null) return null;

    final exists = _box.containsKey(updatedNote.id);
    if (!exists) return null;

    await _box.put(updatedNote.id, updatedNote.toMap());
    return updatedNote;
  }

  /// 📋 Ambil semua catatan tersimpan
  Future<List<Note>> getAllNotes() async {
    final notes = <Note>[];

    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is Map) {
        notes.add(Note.fromMap(key as int, Map<String, dynamic>.from(raw)));
      }
    }

    // Urutkan dari yang terbaru
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }

  /// 🗑️ Hapus catatan berdasarkan ID
  Future<void> deleteNote(int id) async {
    await _box.delete(id);
  }

  /// 🔍 Ambil satu catatan berdasarkan ID
  Future<Note?> getNoteById(int id) async {
    final raw = _box.get(id);
    if (raw is Map) {
      return Note.fromMap(id, Map<String, dynamic>.from(raw));
    }
    return null;
  }
}
