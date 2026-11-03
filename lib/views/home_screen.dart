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
/// of the search bar, empty/loading/error states, duplicate city picker,
/// offline warning banner, current weather card, and 5-day forecast.
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
            _checkAndShowCityPicker(vm);

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

    // Scrollable container ensuring no overflow in landscape or on small screens
    return ListView(
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
    );
  }
}
