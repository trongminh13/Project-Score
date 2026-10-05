import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../extensions/context_ext.dart';

class AppSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final Duration debounceDuration;
  final EdgeInsetsGeometry padding;

  const AppSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = 'Tìm kiếm...',
    this.debounceDuration = const Duration(milliseconds: 300),
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.l),
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onChanged(query.toLowerCase());
    });
    setState(() {}); // trigger rebuild for suffix icon
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontSize: 14,
          color: context.colors.onSurface,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontSize: 14,
            color: context.colorsExt.textMuted,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: context.colorsExt.textMuted,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.cancel_rounded, size: 18),
                  color: context.colorsExt.textMuted,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  onPressed: () {
                    _controller.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
        ),
      ),
    );
  }
}
