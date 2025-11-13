import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/notes_list_bloc.dart';
import '../blocs/note_form_cubit.dart';
import '../repositories/notes_repository.dart';
import '../models/note.dart';
import 'add_edit_note_screen.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Saya'),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocBuilder<NotesListBloc, NotesListState>(
          builder: (context, state) {
            if (state is NotesListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotesListLoaded) {
              final notes = state.notes;

              if (notes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.note_outlined,
                          size: 72, color: Colors.lightBlue),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada catatan.\nTekan tombol + untuk menambah.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: Colors.lightBlue,
                onRefresh: () async {
                  context.read<NotesListBloc>().add(RefreshNotes());
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: notes.length,
                  itemBuilder: (context, idx) {
                    final note = notes[idx];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shadowColor: Colors.blue.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        title: Text(
                          note.title.isEmpty ? '(Tanpa Judul)' : note.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        onTap: () {
                          // Tetap bisa edit juga dengan tap keseluruhan tile
                          _navigateToEdit(context, note);
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ✏️ Tombol Edit
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.lightBlue),
                              tooltip: 'Edit catatan',
                              onPressed: () => _navigateToEdit(context, note),
                            ),
                            // 🗑️ Tombol Hapus
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              tooltip: 'Hapus catatan',
                              onPressed: () {
                                if (note.id != null) {
                                  context
                                      .read<NotesListBloc>()
                                      .add(DeleteNoteEvent(note.id!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Catatan dihapus'),
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              return const Center(
                  child: Text('Terjadi kesalahan saat memuat data.'));
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RepositoryProvider.value(
                value: context.read<NotesRepository>(),
                child: BlocProvider(
                  create: (ctx) =>
                      NoteFormCubit(repository: ctx.read<NotesRepository>()),
                  child: const AddEditNoteScreen(isEditing: false),
                ),
              ),
            ),
          ).then((_) {
            context.read<NotesListBloc>().add(RefreshNotes());
          });
        },
      ),
    );
  }

  /// 🔁 Navigasi ke halaman edit
  void _navigateToEdit(BuildContext context, Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RepositoryProvider.value(
          value: context.read<NotesRepository>(),
          child: BlocProvider(
            create: (ctx) => NoteFormCubit(
              repository: ctx.read<NotesRepository>(),
            )..load(note),
            child: const AddEditNoteScreen(isEditing: true),
          ),
        ),
      ),
    ).then((_) {
      context.read<NotesListBloc>().add(RefreshNotes());
    });
  }
}
