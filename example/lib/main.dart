import 'package:flutter/material.dart';
import 'package:iconify_design/iconify_design.dart';

void main() {
  runApp(const IconifyDesignExample());
}

class IconifyDesignExample extends StatelessWidget {
  const IconifyDesignExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iconify Design Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        useMaterial3: true,
      ),
      home: const ExampleHome(),
    );
  }
}

class ExampleHome extends StatelessWidget {
  const ExampleHome({super.key});

  static const validIcons = [
    'logos:flutter',
    'skill-icons:flutter-light',
    'logos:facebook',
    'line-md:instagram',
    'hugeicons:tiktok',
    'fluent:home-24-filled',
    'mage:phone-fill',
    'material-symbols:hotel-class-rounded',
  ];

  static const invalidIcons = [
    'missing-prefix',
    'unknown:icon-name',
    ':empty-prefix',
    'empty-icon:',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iconify Design'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _IntroPanel(),
          SizedBox(height: 16),
          _Section(
            title: 'Basic Usage',
            child: _BasicUsageDemo(),
          ),
          _Section(
            title: 'Size and Color',
            child: _SizeAndColorDemo(),
          ),
          _Section(
            title: 'Custom Placeholder',
            child: _PlaceholderDemo(),
          ),
          _Section(
            title: 'Custom Error Widgets',
            child: _ErrorDemo(),
          ),
          _Section(
            title: 'Icon Grid',
            child: _IconGridDemo(),
          ),
          _Section(
            title: 'Buttons',
            child: _ButtonDemo(),
          ),
        ],
      ),
    );
  }
}

class _IntroPanel extends StatelessWidget {
  const _IntroPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const IconifyIcon(
              icon: 'logos:flutter',
              size: 52,
              errorWidget: Icon(Icons.extension_off, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Examples for default icons, custom size and color, loading placeholders, error widgets, and button icons.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      height: 1.35,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E5EA)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _BasicUsageDemo extends StatelessWidget {
  const _BasicUsageDemo();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 18,
      runSpacing: 18,
      children: [
        _IconExample(
          label: 'Default',
          icon: IconifyIcon(icon: 'mdi:home'),
        ),
        _IconExample(
          label: 'Explicit size',
          icon: IconifyIcon(icon: 'mdi:bell', size: 36),
        ),
        _IconExample(
          label: 'Black fallback',
          icon: IconifyIcon(icon: 'mdi:account-circle-outline'),
        ),
      ],
    );
  }
}

class _SizeAndColorDemo extends StatelessWidget {
  const _SizeAndColorDemo();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 18,
      runSpacing: 18,
      children: [
        _IconExample(
          label: 'Blue, 48',
          icon: IconifyIcon(
            icon: 'iconoir:fill-color-solid',
            size: 48,
            color: Colors.blue,
          ),
        ),
        _IconExample(
          label: 'Green, 64',
          icon: IconifyIcon(
            icon: 'radix-icons:size',
            size: 64,
            color: Colors.green,
          ),
        ),
        _IconExample(
          label: 'Red, 32',
          icon: IconifyIcon(
            icon: 'mdi:heart',
            size: 32,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}

class _PlaceholderDemo extends StatelessWidget {
  const _PlaceholderDemo();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 18,
      runSpacing: 18,
      children: [
        const _IconExample(
          label: 'Default loader',
          icon: IconifyIcon(
            icon: 'mdi:cloud-download-outline',
            size: 36,
          ),
        ),
        _IconExample(
          label: 'Custom loader',
          icon: IconifyIcon(
            icon: 'mdi:timer-sand',
            size: 36,
            placeholder: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const SizedBox.square(
                dimension: 40,
                child: Center(
                  child: SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorDemo extends StatelessWidget {
  const _ErrorDemo();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 18,
      runSpacing: 18,
      children: ExampleHome.invalidIcons.map((icon) {
        return _IconExample(
          label: icon,
          icon: const IconifyIcon(
            icon: 'invalid-icon',
            errorWidget: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 32,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _IconGridDemo extends StatelessWidget {
  const _IconGridDemo();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720
            ? 4
            : constraints.maxWidth >= 420
                ? 3
                : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ExampleHome.validIcons.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.9,
          ),
          itemBuilder: (context, index) {
            final icon = ExampleHome.validIcons[index];

            return DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E5EA)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    IconifyIcon(
                      icon: icon,
                      size: 28,
                      errorWidget: const Icon(Icons.extension_off),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        icon,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ButtonDemo extends StatelessWidget {
  const _ButtonDemo();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const IconifyIcon(
            icon: 'mdi:refresh',
            size: 20,
          ),
          label: const Text('Reload'),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const IconifyIcon(
            icon: 'mdi:download',
            color: Colors.white,
            size: 20,
          ),
          label: const Text('Download'),
        ),
        IconButton.filledTonal(
          onPressed: () {},
          icon: const IconifyIcon(
            icon: 'mdi:heart',
            color: Colors.red,
            size: 22,
          ),
        ),
      ],
    );
  }
}

class _IconExample extends StatelessWidget {
  const _IconExample({
    required this.label,
    required this.icon,
  });

  final String label;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 72,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E5EA)),
              ),
              child: Center(child: icon),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
