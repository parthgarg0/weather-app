import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../data/models/daily_forecast.dart';

/// Renders a single row entry within the 5-day forecast list.
class ForecastTile extends StatelessWidget {
  final DailyForecast forecast;
  final bool isFahrenheit;

  const ForecastTile({
    super.key,
    required this.forecast,
    required this.isFahrenheit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final condition = WeatherCodeMapper.map(forecast.weatherCode);
    final unit = isFahrenheit ? AppStrings.unitFahrenheit : AppStrings.unitCelsius;

    // Format date as "Mon, 4 Nov"
    final formattedDate = DateFormat('E, d MMM').format(forecast.date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Day and date
          SizedBox(
            width: 90,
            child: Text(
              formattedDate,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Weather icon & condition description
          Expanded(
            child: Row(
              children: [
                Text(
                  condition.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    condition.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Min / Max temperature
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${forecast.minTemperature.round()}$unit',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                ' / ',
                style: TextStyle(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              Text(
                '${forecast.maxTemperature.round()}$unit',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
