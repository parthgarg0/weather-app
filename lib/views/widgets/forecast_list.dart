import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../data/models/daily_forecast.dart';
import 'forecast_tile.dart';

/// Container widget that presents the multi-day weather forecast.
class ForecastList extends StatelessWidget {
  final List<DailyForecast> forecasts;
  final bool isFahrenheit;

  const ForecastList({
    super.key,
    required this.forecasts,
    required this.isFahrenheit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.forecastTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            ...forecasts.asMap().entries.map((entry) {
              final index = entry.key;
              final forecast = entry.value;

              return Column(
                children: [
                  ForecastTile(
                    forecast: forecast,
                    isFahrenheit: isFahrenheit,
                  ),
                  if (index < forecasts.length - 1)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
