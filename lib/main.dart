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
      child: Consumer<WeatherViewModel>(
        builder: (context, vm, _) {
          return MaterialApp(
            title: AppStrings.appTitle,
            debugShowCheckedModeBanner: false,

            // Directly driven by the ViewModel's persisted theme state
            themeMode: vm.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            // Material 3 Light Theme
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF7F8FC),
              cardTheme: CardThemeData(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: Colors.indigo.shade50,
                    width: 1,
                  ),
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
              scaffoldBackgroundColor: const Color(0xFF111318),
              cardTheme: CardThemeData(
                elevation: 0,
                color: const Color(0xFF1E2129),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),

            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
