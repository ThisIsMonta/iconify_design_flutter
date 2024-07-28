import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconify_design/src/services/api_service.dart';

class IconifyIcon extends StatefulWidget {
  final String icon;
  final double? size;
  final Color? color;
  
  const IconifyIcon(
      {super.key, required this.icon, this.size = 24, this.color});

  @override
  State<IconifyIcon> createState() => _IconifyIconState();
}

class _IconifyIconState extends State<IconifyIcon> {
  Future getIcon() async {
    final prefix = widget.icon.split(":")[0];
    final icon = widget.icon.split(":")[1];
    if (prefix.isEmpty || icon.isEmpty) return null;
    final response = await ClientService().getRequest('$prefix/$icon.svg');
    
    return response.fold((l) {
      return null;
    }, (r) {
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
              color: widget.color,
            );
        }
      },
    );
  }
}
