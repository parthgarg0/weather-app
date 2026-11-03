import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../data/models/weather_data.dart';

/// Card presenting the primary current weather metrics for the active city.
///
/// Displays city & country, temperature with unit, condition emoji + description,
/// humidity percentage, and wind speed.
class CurrentWeatherCard extends StatelessWidget {
  final WeatherData weatherData;

  const CurrentWeatherCard({
    super.key,
    required this.weatherData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = weatherData.current;
    final city = weatherData.city;
    final condition = WeatherCodeMapper.map(current.weatherCode);
    final unit = weatherData.isFahrenheit
        ? AppStrings.unitFahrenheit
        : AppStrings.unitCelsius;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // City name and location details
            Text(
              city.name,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              city.locationDetails,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Condition icon emoji and current temperature
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  condition.icon,
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(width: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current.temperature.round().toString(),
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        fontSize: 64,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        unit,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Weather description text
            Text(
              condition.description,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // Bottom metrics row: Humidity and Wind Speed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(
                  context: context,
                  icon: Icons.water_drop_outlined,
                  label: AppStrings.humidityLabel,
                  value: '${current.relativeHumidity}%',
                ),
                Container(
                  height: 36,
                  width: 1,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                _buildMetricItem(
                  context: context,
                  icon: Icons.air_rounded,
                  label: AppStrings.windSpeedLabel,
                  value: '${current.windSpeed.toStringAsFixed(1)} ${AppStrings.unitKmH}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
