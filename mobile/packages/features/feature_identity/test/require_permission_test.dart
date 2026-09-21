import 'package:feature_identity/feature_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';

import 'test_session.dart';

Widget host(Widget child, {required Set<String> permissions}) => ProviderScope(
  overrides: [
    sessionProvider.overrideWithValue(testSession(permissions: permissions)),
  ],
  child: MaterialApp(
    theme: WmsTheme.light(),
    home: Scaffold(body: child),
  ),
);

void main() {
  testWidgets('renders the child only with the permission', (tester) async {
    await tester.pumpWidget(
      host(
        const RequirePermission(
          permission: Permissions.productViewCost,
          child: Text('maya dəyəri'),
        ),
        permissions: {Permissions.productViewCost},
      ),
    );
    expect(find.text('maya dəyəri'), findsOneWidget);
  });

  testWidgets('hides the subtree entirely without the permission (no mask)', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const RequirePermission(
          permission: Permissions.productViewCost,
          child: Text('maya dəyəri'),
        ),
        permissions: {Permissions.balanceView},
      ),
    );
    expect(find.text('maya dəyəri'), findsNothing);
    expect(find.textContaining('***'), findsNothing);
  });

  testWidgets('withNotice explains the missing permission', (tester) async {
    await tester.pumpWidget(
      host(
        const RequirePermission.withNotice(
          permission: Permissions.poApprove,
          child: Text('təsdiq paneli'),
        ),
        permissions: const {},
      ),
    );
    expect(find.text('təsdiq paneli'), findsNothing);
    expect(find.text('Bu bölmə üçün icazəniz yoxdur'), findsOneWidget);
  });
}
