import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/note_form_cubit.dart';

class AddEditNoteScreen extends StatefulWidget {
  final bool isEditing;
  const AddEditNoteScreen({super.key, this.isEditing = false});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    final note = context.read<NoteFormCubit>().state.note;
    _titleController = TextEditingController(text: note.title);
    _contentController = TextEditingController(text: note.content);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Catatan' : 'Buat Catatan'),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            tooltip: 'Simpan Catatan',
            onPressed: _onSave,
            icon: const Icon(Icons.save_rounded, color: Colors.white),
          ),
        ],
      ),
      body: BlocListener<NoteFormCubit, NoteFormState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (!state.saving && state.note.id != null) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Catatan berhasil disimpan'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Judul',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                ),
                onChanged: (v) => context.read<NoteFormCubit>().updateTitle(v),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: 'Tulis catatan kamu di sini...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(fontSize: 16),
                  onChanged: (v) => context.read<NoteFormCubit>().updateContent(v),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _onSave,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(isEditing ? 'Simpan Perubahan' : 'Simpan Catatan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    final cubit = context.read<NoteFormCubit>();
    await cubit.save();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose(); // ✅ sudah diperbaiki di sini
    super.dispose();
  }
}
