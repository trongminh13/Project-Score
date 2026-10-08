import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../features/settings/domain/app_language.dart';
import '../error/response_status.dart';
import '../theme/app_colors_extension.dart';

/// Consolidated [BuildContext] extensions for screen metrics, theming,
/// and localization access.
extension ContextExtension on BuildContext {
  // ── Screen Metrics ──────────────────────────────────────────────

  /// Full screen width (equivalent to `MediaQuery.sizeOf(this).width`).
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Full screen height (equivalent to `MediaQuery.sizeOf(this).height`).
  double get screenHeight => MediaQuery.sizeOf(this).height;

  // ── Theme Shortcuts ──────────────────────────────────────────────

  /// Shortcut for `Theme.of(context).colorScheme`.
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Shortcut for `Theme.of(context).extension<AppColorsExtension>()!`.
  AppColorsExtension get colorsExt =>
      Theme.of(this).extension<AppColorsExtension>()!;

  /// Shortcut for `Theme.of(context).textTheme`.
  TextTheme get textTheme => Theme.of(this).textTheme;

  // ── Localization ────────────────────────────────────────────────

  /// Shortcut for `S.of(context)` — generated l10n accessor.
  S get l10n => S.of(this);

  /// Current locale's language code (e.g., `'en'` or `'ar'`).
  String get localeName => Localizations.localeOf(this).languageCode;
  /// Translate dynamic stat names and category names from API to local language.
  String translateStatName(String englishName) {
    if (localeName != 'vi') return englishName;

    final lower = englishName.toLowerCase().trim();
    return switch (lower) {
      // Categories
      'shots' => 'Cú sút',
      'passes' => 'Chuyền bóng',
      'discipline' => 'Kỷ luật',
      'defense' => 'Phòng ngự',
      'duels' => 'Tranh chấp',
      'attacks' => 'Tấn công',
      'general' => 'Tổng quan',
      
      // Specific Stats
      'ball possession' || 'possession' => 'Kiểm soát bóng',
      'expected goals' || 'expected goals (xg)' || 'xg' => 'Bàn thắng kỳ vọng (xG)',
      'total shots' => 'Tổng cú sút',
      'shots on target' => 'Sút trúng đích',
      'shots off target' => 'Sút chệch cột',
      'blocked shots' => 'Sút bị chặn',
      'corner kicks' || 'corners' => 'Phạt góc',
      'offsides' => 'Việt vị',
      'fouls' => 'Phạm lỗi',
      'yellow cards' => 'Thẻ vàng',
      'red cards' => 'Thẻ đỏ',
      'goalkeeper saves' || 'saves' => 'Cứu thua',
      'total passes' => 'Đường chuyền',
      'accurate passes' => 'Chuyền chính xác',
      'accurate passes %' => 'Tỷ lệ chuyền chính xác',
      'big chances' => 'Cơ hội rõ rệt',
      'hit woodwork' => 'Chạm khung gỗ',
      'dangerous attacks' => 'Tấn công nguy hiểm',
      'throw-ins' => 'Ném biên',
      'crosses' => 'Tạt bóng',
      'tackles' => 'Tắc bóng',
      'interceptions' => 'Cắt bóng',
      'clearances' => 'Phá bóng',
      'free kicks' => 'Đá phạt',
      'goal kicks' => 'Phát bóng',
      _ => englishName,
    };
  }
}

/// Helper extensions on the generated [S] class.
extension AppL10nHelpers on S {
  String bottomNavigationTitle(int index) {
    return switch (index) {
      0 => liveScore,
      1 => fixtures,
      2 => standings,
      _ => liveScore,
    };
  }

  String themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => systemDefault,
      ThemeMode.light => light,
      ThemeMode.dark => dark,
    };
  }

  String languageLabel(AppLanguage language) {
    return switch (language) {
      AppLanguage.system => systemDefault,
      AppLanguage.english => english,
      AppLanguage.arabic => arabic,
      AppLanguage.vietnamese => vietnamese,
    };
  }

  String errorMessage(String key) {
    return switch (key) {
      StatusMessage.clientClosedRequestKey => errorClientClosedRequest,
      StatusMessage.internalServerErrorKey => errorInternalServerError,
      StatusMessage.networkConnectErrorKey => errorNetworkConnectError,
      StatusMessage.webProxyRequiredKey => errorWebProxyRequired,
      StatusMessage.unexpectedKey => errorUnexpected,
      _ => key, // Return the raw custom message if it's not a known key
    };
  }
}
