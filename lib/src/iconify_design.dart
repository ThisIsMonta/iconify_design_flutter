import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconify_design/src/services/api_service.dart';

/// A widget that displays an SVG icon fetched from a remote source or local cache.
class IconifyIcon extends StatefulWidget {
  /// The identifier of the icon to be displayed. The format should be "prefix:icon".
  final String icon;

  /// The size of the icon. Default is 24.0.
  final double? size;

  /// The color of the icon. Default is black.
  final Color? color;

  /// The widget to display while the icon is loading.
  final Widget? placeholder;

  /// The widget to display when the icon cannot be loaded.
  final Widget? errorWidget;

  /// Creates an [IconifyIcon] widget.
  const IconifyIcon({
    super.key,
    required this.icon,
    this.size = 24,
    this.color = Colors.black,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<IconifyIcon> createState() => _IconifyIconState();
}

class _IconifyIconState extends State<IconifyIcon> {
  String? _iconData;
  Future<String?>? _iconFuture;

  @override
  void didUpdateWidget(IconifyIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.icon != oldWidget.icon) {
      _iconData = null;
      _iconFuture = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _iconData ??= IconifyClientService.memoryGet(
        IconifyClientService.iconKey(widget.icon));
    if (data != null) return _renderIcon(data);

    return FutureBuilder<String?>(
      future: _iconFuture ??= IconifyClientService().resolveIcon(widget.icon),
      builder: (_, AsyncSnapshot<String?> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.waiting:
            return widget.placeholder ?? _defaultPlaceholder();
          case ConnectionState.none:
            return const SizedBox.shrink();
          case ConnectionState.done:
            _iconFuture = null;
            if (snapshot.hasError || snapshot.data == null) {
              return widget.errorWidget ?? const SizedBox.shrink();
            }
            _iconData = snapshot.data;
            return _renderIcon(snapshot.data!);
        }
      },
    );
  }

  Widget _renderIcon(String data) {
    return SvgPicture.string(
      data,
      width: widget.size,
      height: widget.size,
      theme: SvgTheme(currentColor: widget.color ?? Colors.black),
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: widget.size,
      padding: const EdgeInsets.all(2.0),
      child: const AspectRatio(
        aspectRatio: 1,
        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 1),
      ),
    );
  }
}
