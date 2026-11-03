import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';

/// Reusable search input field customized for city queries.
///
/// Handles input submission, clearing, keyboard actions, and displays
/// gentle inline validation feedback.
class CitySearchBar extends StatefulWidget {
  final ValueChanged<String> onSubmitted;
  final String? validationError;
  final VoidCallback onClearValidation;

  const CitySearchBar({
    super.key,
    required this.onSubmitted,
    this.validationError,
    required this.onClearValidation,
  });

  @override
  State<CitySearchBar> createState() => _CitySearchBarState();
}

class _CitySearchBarState extends State<CitySearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    final bool currentHasText = _controller.text.isNotEmpty;
    if (_hasText != currentHasText) {
      setState(() {
        _hasText = currentHasText;
      });
    }
    if (widget.validationError != null) {
      widget.onClearValidation();
    }
  }

  void _submit() {
    final text = _controller.text;
    _focusNode.unfocus();
    widget.onSubmitted(text);
  }

  void _clear() {
    _controller.clear();
    widget.onClearValidation();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: widget.validationError != null
                  ? theme.colorScheme.error
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: AppStrings.searchPrompt,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.primary,
              ),
              suffixIcon: _hasText
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      tooltip: 'Clear',
                      onPressed: _clear,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
            ),
          ),
        ),
        if (widget.validationError != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              widget.validationError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
