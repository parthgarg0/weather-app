import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../viewmodels/weather_viewmodel.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/search_bar.dart';

/// The primary view of the Weather application.
///
/// Reacts to state changes in [WeatherViewModel] and coordinates the presentation
/// of the search bar, empty/loading/error states, current weather, and forecasts.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.appTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<WeatherViewModel>(
          builder: (context, vm, child) {
            return Column(
              children: [
                // Top Search Bar Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: CitySearchBar(
                    validationError: vm.validationError,
                    onClearValidation: vm.clearValidationError,
                    onSubmitted: (query) => vm.searchCity(query),
                  ),
                ),

                // Main State-driven Content Area
                Expanded(
                  child: _buildBody(context, vm, theme),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WeatherViewModel vm,
    ThemeData theme,
  ) {
    if (vm.isLoading) {
      return const LoadingView();
    }

    if (vm.errorMessage != null) {
      return ErrorView(
        message: vm.errorMessage!,
        onRetry: vm.retryLastAction,
      );
    }

    if (vm.isEmpty) {
      return const EmptyView();
    }

    // Placeholder for weather data display (populated in commit 10)
    return Center(
      child: Text(
        'Weather loaded for ${vm.weatherData?.city.name}',
        style: theme.textTheme.titleMedium,
      ),
    );
  }
}
