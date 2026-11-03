import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'data/repositories/weather_repository.dart';
import 'data/services/cache_service.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized before accessing SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local persistent cache service
  final cacheService = await CacheService.create();

  // Create repository providing single source of truth for weather operations
  final weatherRepository = WeatherRepository(cacheService: cacheService);

  runApp(WeatherApp(repository: weatherRepository));
}

/// Root widget of the application.
///
/// Sets up dependency injection via Provider, configures Material 3 theme
/// supporting automatic light and dark mode switching following the host operating system.
class WeatherApp extends StatelessWidget {
  final WeatherRepository repository;

  const WeatherApp({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // The ViewModel is created here and immediately initializes stored settings & cache
      create: (_) => WeatherViewModel(repository: repository)..initialize(),
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,

        // ThemeMode.system enables automatic switching between light and dark themes
        themeMode: ThemeMode.system,

        // Material 3 Light Theme
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
          cardTheme: const CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
        ),

        // Material 3 Dark Theme
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          cardTheme: const CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
        ),

        home: const HomeScreen(),
      ),
    );
  }
}
