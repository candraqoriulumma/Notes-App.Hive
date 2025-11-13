import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'blocs/notes_list_bloc.dart';
import 'repositories/notes_repository.dart';
import 'screens/notes_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🧠 Inisialisasi Hive
  await Hive.initFlutter();

  // 🗂️ Buka atau buat box untuk menyimpan catatan
  final notesBox = await Hive.openBox('notesBox');

  // 🔗 Inisialisasi repository dengan box yang sudah dibuka
  final notesRepository = NotesRepository(notesBox);

  // 🚀 Jalankan aplikasi
  runApp(MyApp(notesRepository: notesRepository));
}

class MyApp extends StatelessWidget {
  final NotesRepository notesRepository;

  const MyApp({super.key, required this.notesRepository});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: notesRepository,
      child: BlocProvider(
        create: (_) =>
            NotesListBloc(repository: notesRepository)..add(LoadNotes()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Notes App (Hive)',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.lightBlue,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.blue.shade50,

            // 🌟 AppBar
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            // 🌟 Tombol tambah
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),

            // 🌟 Kartu catatan
            cardTheme: const CardThemeData(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 3,
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
          home: const NotesListScreen(),
        ),
      ),
    );
  }
}
