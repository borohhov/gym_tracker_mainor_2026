import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/controllers/auth_provider.dart';
import 'package:gym_tracker/controllers/exercise_log_provider.dart';
import 'package:gym_tracker/theme/app_theme.dart';
import 'package:gym_tracker/views/home.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyRootApp());
}

class MyRootApp extends StatelessWidget {
  const MyRootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<ExerciseLogProvider>(
          create: (_) => ExerciseLogProvider(),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _storageReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configureStorage();
  }

  Future<void> _configureStorage() async {
    final authProvider = context.read<AuthProvider>();
    final logProvider = context.read<ExerciseLogProvider>();

    if (authProvider.isLoggedIn) {
      await logProvider.useAuthenticatedMode(authProvider.currentUser!.uid);
    } else {
      await logProvider.useGuestMode();
    }

    if (mounted) {
      setState(() {
        _storageReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Tracker',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: _storageReady
          ? const HomeScreen()
          : const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}