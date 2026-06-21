import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_lens/design_system/layouts/base/scaffold.dart';
import 'package:money_lens/design_system/layouts/page/page.dart';
import 'package:money_lens/design_system/layouts/responsive/responsive_layout.dart';
import 'package:money_lens/design_system/theme/dark_theme.dart';

void main() {
  testWidgets('MLScaffold renders body correctly', (WidgetTester tester) async {
    const key = Key('scaffold_body');
    await tester.pumpWidget(
      MaterialApp(
        theme: mldsDarkTheme,
        home: const MLScaffold(
          animateEntrance: false,
          body: SizedBox(key: key),
        ),
      ),
    );

    expect(find.byKey(key), findsOneWidget);
  });

  testWidgets('MLResponsiveContainer selects layout based on width', (
    WidgetTester tester,
  ) async {
    const phoneKey = Key('phone_layout');
    const tabletKey = Key('tablet_layout');
    const desktopKey = Key('desktop_layout');

    // Test phone size (360 width)
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: mldsDarkTheme,
        home: const Scaffold(
          body: MLResponsiveContainer(
            phone: SizedBox(key: phoneKey),
            tablet: SizedBox(key: tabletKey),
            desktop: SizedBox(key: desktopKey),
          ),
        ),
      ),
    );

    expect(find.byKey(phoneKey), findsOneWidget);
    expect(find.byKey(tabletKey), findsNothing);
    expect(find.byKey(desktopKey), findsNothing);

    // Test tablet size (768 width)
    tester.view.physicalSize = const Size(768, 1024);
    await tester.pump();

    expect(find.byKey(tabletKey), findsOneWidget);
    expect(find.byKey(phoneKey), findsNothing);
    expect(find.byKey(desktopKey), findsNothing);

    // Test desktop size (1200 width)
    tester.view.physicalSize = const Size(1200, 800);
    await tester.pump();

    expect(find.byKey(desktopKey), findsOneWidget);
    expect(find.byKey(phoneKey), findsNothing);
    expect(find.byKey(tabletKey), findsNothing);
  });

  testWidgets('MLGrid arranges elements correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: mldsDarkTheme,
        home: Scaffold(
          body: MLGrid(
            crossAxisCount: 3,
            children: List.generate(6, (index) => Text('Item $index')),
          ),
        ),
      ),
    );

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 5'), findsOneWidget);
  });

  testWidgets(
    'MLScrollablePage structures sections vertically with custom spacing',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: mldsDarkTheme,
          home: const Scaffold(
            body: MLScrollablePage(
              header: Text('Global Header'),
              spacing: 24.0,
              children: [Text('Child A'), Text('Child B')],
            ),
          ),
        ),
      );

      expect(find.text('Global Header'), findsOneWidget);
      expect(find.text('Child A'), findsOneWidget);
      expect(find.text('Child B'), findsOneWidget);
    },
  );
}
