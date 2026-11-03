import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_strings.dart';

/// Banner shown when displaying cached weather data due to network unavailability.
///
/// Prominently communicates to the user that the information is from a local snapshot
/// and specifies when it was captured.
class OfflineBanner extends StatelessWidget {
  final DateTime? savedTimestamp;
  final VoidCallback? onRetry;

  const OfflineBanner({
    super.key,
    this.savedTimestamp,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Format the timestamp nicely, e.g. "4 Nov, 2:30 PM"
    final String formattedTime = savedTimestamp != null
        ? DateFormat('d MMM, h:mm a').format(savedTimestamp!.toLocal())
        : 'earlier';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.amber.shade900.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.shade800.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 20,
            color: Colors.amber.shade800,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.offlineBannerText(formattedTime),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              tooltip: AppStrings.retryButton,
              onPressed: onRetry,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }
}
