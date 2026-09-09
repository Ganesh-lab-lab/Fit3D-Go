import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/state/roomfit_state.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
      home: HomeScreen(state: state),
    );
  }
}
