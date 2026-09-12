import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/supabase_service.dart';
import 'core/state/roomfit_state.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/home/presentation/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  debugPrint('✅ Supabase initialized');

  // Set system overlay for immersive OriginOS dark glass style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  final globalState = RoomFitState();
  runApp(RoomFitApp(state: globalState));
}

class RoomFitApp extends StatelessWidget {
  final RoomFitState state;

  const RoomFitApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoomFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: AuthGate(state: state),
    );
  }
}

/// AuthGate monitors Supabase authentication status and directs
/// the user to either the AuthScreen or the HomeScreen.
class AuthGate extends StatefulWidget {
  final RoomFitState state;

  const AuthGate({super.key, required this.state});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<AuthState> _authSubscription;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkInitialAuth();

    _authSubscription =
        SupabaseService.instance.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        await widget.state.loadFromSupabase();
      } else {
        widget.state.clearLocalState();
      }
      if (mounted) setState(() {});
    });
  }

  Future<void> _checkInitialAuth() async {
    if (SupabaseService.instance.isAuthenticated) {
      await widget.state.loadFromSupabase();
    }
    if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryCyan,
          ),
        ),
      );
    }

    if (SupabaseService.instance.isAuthenticated) {
      return HomeScreen(state: widget.state);
    } else {
      return AuthScreen(state: widget.state);
    }
  }
}
