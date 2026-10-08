import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_decorations.dart';

/// Represents the custom image entity/model.
class CustomImage extends StatelessWidget {
  const CustomImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.placeholder,
    this.errorWidget,
    this.fit,
    this.borderRadius,
    this.border,
    this.shadow,
  });

  final String imageUrl;
  final double? height;
  final double? width;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final BoxShadow? shadow;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    
    String safeUrl = imageUrl;

    if (safeUrl.toLowerCase().endsWith('.svg')) {
      imageWidget = SvgPicture.network(
        imageUrl,
        height: height,
        width: width,
        fit: fit ?? BoxFit.contain,
        placeholderBuilder: (_) => placeholder ?? _buildPlaceholder(context),
      );
    } else {
      if (kIsWeb) {
        imageWidget = Image.network(
          safeUrl,
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (_, __, ___) => errorWidget ?? const SizedBox.shrink(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return placeholder ?? _buildPlaceholder(context);
          },
        );
      } else {
        imageWidget = CachedNetworkImage(
          imageUrl: safeUrl,
          height: height,
          width: width,
          fit: fit,
          fadeInDuration: const Duration(milliseconds: 300),
          placeholder: (_, _) => placeholder ?? _buildPlaceholder(context),
          errorWidget: (_, _, _) => errorWidget ?? const SizedBox.shrink(),
        );
      }
    }

    if (borderRadius != null || border != null || shadow != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: border,
          boxShadow: shadow != null ? [shadow!] : null,
        ),
        clipBehavior: borderRadius != null ? Clip.hardEdge : Clip.none,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder(BuildContext context) {
    // On web, Shimmer (ShaderMask) can sometimes render as a solid black box.
    // We use a simple soft-colored container instead.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white12 : Colors.black12;
    
    if (kIsWeb) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: borderRadius ?? AppBorderRadius.smallAll,
        ),
      );
    }
    
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: isDark ? Colors.white24 : Colors.black26,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? AppBorderRadius.smallAll,
        ),
      ),
    );
  }
}
