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
  /// Current icon id this state is resolving.
  String _icon = '';

  /// The future that is currently fetching the [_icon].
  late Future<String?> _iconFuture;

  @override
  void initState() {
    super.initState();
    _setIcon(widget.icon);
  }

  @override
  void didUpdateWidget(IconifyIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.icon != _icon) _setIcon(widget.icon);
  }

  // Update the icon that this state is handling.
  void _setIcon(String icon) {
    _icon = icon;
    _iconFuture = IconifyClientService().resolveIcon(icon);
  }

  /// Reads the icon's data from the in-memory cache.
  String? get _memoryIcon =>
      IconifyClientService.memoryGet(IconifyClientService.iconKey(_icon));

  @override
  Widget build(BuildContext context) {
    // return icon from memory if available
    final memoryIcon = _memoryIcon;
    if (memoryIcon != null) return _renderIcon(memoryIcon);

    return FutureBuilder<String?>(
      future: _iconFuture,
      builder: (_, AsyncSnapshot<String?> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.waiting:
            return widget.placeholder ?? _defaultPlaceholder();
          case ConnectionState.none:
            return const SizedBox.shrink();
          case ConnectionState.done:
            if (snapshot.hasError || snapshot.data == null) {
              return widget.errorWidget ?? const SizedBox.shrink();
            }
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
