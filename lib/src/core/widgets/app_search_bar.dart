import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../extensions/context_ext.dart';

class AppSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final Duration debounceDuration;

  const AppSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = 'Tìm kiếm...',
    this.debounceDuration = const Duration(milliseconds: 300),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: context.colorsExt.textMuted),
          prefixIcon: Icon(CupertinoIcons.search, color: context.colorsExt.textMuted),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(CupertinoIcons.clear_thick_circled, size: 18),
                  color: context.colorsExt.textMuted,
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
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        ),
      ),
    );
  }
}
