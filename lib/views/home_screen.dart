import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../viewmodels/weather_viewmodel.dart';
import 'widgets/city_picker_sheet.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/forecast_list.dart';
import 'widgets/loading_view.dart';
import 'widgets/offline_banner.dart';
import 'widgets/search_bar.dart';

/// The primary view of the Weather application.
///
/// Reacts to state changes in [WeatherViewModel] and coordinates the presentation
/// of the search bar, search history chips, empty/loading/error states, duplicate
/// city picker, offline warning banner, pull-to-refresh, current weather card,
/// and 5-day forecast.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isPickerOpen = false;

  void _checkAndShowCityPicker(WeatherViewModel vm) {
    if (vm.matchedCities.length > 1 && !_isPickerOpen) {
      _isPickerOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (bottomSheetContext) => CityPickerSheet(
            cities: vm.matchedCities,
            onCitySelected: (selectedCity) {
              Navigator.pop(bottomSheetContext);
              vm.selectCity(selectedCity);
            },
          ),
        );
        _isPickerOpen = false;
      });
    }
  }

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
        actions: [
          Consumer<WeatherViewModel>(
            builder: (context, vm, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: ActionChip(
                  avatar: Icon(
                    Icons.thermostat_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(
                    vm.isFahrenheit
                        ? AppStrings.unitFahrenheit
                        : AppStrings.unitCelsius,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  tooltip: 'Toggle Celsius / Fahrenheit',
                  onPressed: () => vm.toggleTemperatureUnit(),
                  visualDensity: VisualDensity.compact,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<WeatherViewModel>(
          builder: (context, vm, child) {
            _checkAndShowCityPicker(vm);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Search Bar Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
                  child: CitySearchBar(
                    validationError: vm.validationError,
                    onClearValidation: vm.clearValidationError,
                    onSubmitted: (query) => vm.searchCity(query),
                  ),
                ),

                // Recent Search History Chips
                if (vm.searchHistory.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 6.0),
                    child: SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: vm.searchHistory.length + 1,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          if (index == vm.searchHistory.length) {
                            return TextButton.icon(
                              onPressed: () => vm.clearHistory(),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                              ),
                              label: const Text(
                                AppStrings.clearHistory,
                                style: TextStyle(fontSize: 12),
                              ),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                            );
                          }
                          final cityName = vm.searchHistory[index];
                          return ActionChip(
                            avatar: Icon(
                              Icons.history_rounded,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            label: Text(cityName),
                            onPressed: () => vm.searchCity(cityName),
                            visualDensity: VisualDensity.compact,
                          );
                        },
                      ),
                    ),
                  ),

                // Main State-driven Content Area
                Expanded(
                  child: _buildBody(context, vm),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel vm) {
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

    final weatherData = vm.weatherData;
    if (weatherData == null) {
      return const EmptyView();
    }

    // Wrapped in RefreshIndicator for pull-to-refresh
    return RefreshIndicator(
      onRefresh: vm.refreshWeather,
      child: ListView(
        // AlwaysScrollableScrollPhysics ensures pull-to-refresh operates even when
        // content does not exceed the screen height
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          if (vm.isOffline)
            OfflineBanner(
              savedTimestamp: vm.cachedTimestamp,
              onRetry: vm.refreshWeather,
            ),
          CurrentWeatherCard(weatherData: weatherData),
          const SizedBox(height: 16),
          ForecastList(
            forecasts: weatherData.daily,
            isFahrenheit: weatherData.isFahrenheit,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
