import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconify_design/src/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A widget that displays an SVG icon fetched from a remote source or local cache.
class IconifyIcon extends StatefulWidget {
  /// The identifier of the icon to be displayed. The format should be "prefix:icon".
  final String icon;

  /// The size of the icon. Default is 24.0.
  final double? size;

  /// The color of the icon. Default is black.
  final Color? color;

  /// Creates an [IconifyIcon] widget.
  const IconifyIcon(
      {super.key,
      required this.icon,
      this.size = 24,
      this.color = Colors.black});

  @override
  State<IconifyIcon> createState() => _IconifyIconState();
}

class _IconifyIconState extends State<IconifyIcon> {
  /// Fetches the SVG data for the icon from local cache or remote source.
  Future getIcon() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the icon is already cached locally
    if (prefs.containsKey('icon:${widget.icon}')) {
      return prefs.get('icon:${widget.icon}');
    }

    // Split the icon identifier into prefix and icon name
    final prefix = widget.icon.split(":")[0];
    final icon = widget.icon.split(":")[1];
    if (prefix.isEmpty || icon.isEmpty) return null;

    // Fetch the icon from the remote source
    final response = await ClientService().getRequest('$prefix/$icon.svg');

    // Cache the fetched icon locally and return the data
    return response.fold((l) {
      return null;
    }, (r) async {
      await prefs.setString('icon:${widget.icon}', r.data);
      return r.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIcon(),
      builder: (_, AsyncSnapshot<dynamic> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Container(
              width: widget.size,
              padding: const EdgeInsets.all(2.0),
              child: const AspectRatio(
                aspectRatio: 1,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 1,
                ),
              ),
            );
          case ConnectionState.none:
            return const SizedBox.shrink();
          case ConnectionState.done:
            if (snapshot.data == null) {
              return const SizedBox.shrink();
            }
            return SvgPicture.string(
              snapshot.data,
              width: widget.size,
              height: widget.size,
              theme: SvgTheme(currentColor: widget.color!),
            );
        }
      },
    );
  }
}
