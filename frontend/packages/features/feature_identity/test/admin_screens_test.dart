import 'package:feature_identity/feature_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'fake_identity_repository.dart';
import 'test_session.dart';

const _keeper = UserDto(
  id: 7,
  username: 'keeper',
  fullName: 'Anbardar Kamil',
  email: 'keeper@wms.az',
  phone: '+994 50 000 00 00',
  externalId: 'kc-sub-7',
  locationIds: [3, 4],
  roles: [
    RoleSummaryDto(
      id: 2,
      code: 'WAREHOUSE_KEEPER',
      name: 'Anbardar',
      isSystem: true,
    ),
  ],
  audit: AuditFieldsDto(rowVersion: 4),
);

const _admin = UserDto(
  id: 1,
  username: 'admin',
  fullName: 'Administrator',
  isActive: false,
  roles: [RoleSummaryDto(id: 1, code: 'ADMIN', name: 'Admin', isSystem: true)],
);

const _adminRole = RoleDto(
  id: 1,
  code: 'ADMIN',
  name: 'Administrator',
  isSystem: true,
  permissions: [
    Permissions.userManage,
    Permissions.productViewCost,
    Permissions.poApprove,
    Permissions.receiptCreate,
  ],
);

const _keeperRole = RoleDto(
  id: 2,
  code: 'WAREHOUSE_KEEPER',
  name: 'Anbardar',
  isSystem: true,
  permissions: [Permissions.receiptCreate, Permissions.balanceView],
);

Widget host({
  required Widget child,
  required FakeIdentityRepository repository,
  Set<String> permissions = const {Permissions.userManage},
}) => ProviderScope(
  overrides: [
    identityRepositoryProvider.overrideWithValue(repository),
    sessionProvider.overrideWithValue(testSession(permissions: permissions)),
  ],
  child: MaterialApp(
    theme: WmsTheme.light(),
    locale: WmsL10n.defaultLocale,
    supportedLocales: WmsL10n.supportedLocales,
    localizationsDelegates: WmsL10n.delegates,
    home: child,
  ),
);

void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
          ..physicalSize = const Size(1440, 900)
          ..devicePixelRatio = 1;
    addTearDown(view.reset);
  });

  group('AdminUserListScreen', () {
    testWidgets('lists users with roles, locations and activity', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          child: const AdminUserListScreen(),
          repository: FakeIdentityRepository(userRows: const [_keeper, _admin]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('keeper'), findsOneWidget);
      expect(find.text('Anbardar Kamil'), findsOneWidget);
      expect(find.text('keeper@wms.az'), findsOneWidget);
      expect(find.text('WAREHOUSE_KEEPER'), findsOneWidget);
      expect(find.text('2 lokasiya'), findsOneWidget);
      expect(find.text('bütün lokasiyalar'), findsOneWidget);
      expect(find.text('Aktiv'), findsOneWidget);
      expect(find.text('Deaktiv'), findsOneWidget);
    });

    testWidgets('the search box filters through the API', (tester) async {
      final repository = FakeIdentityRepository(
        userRows: const [_keeper, _admin],
      );
      await tester.pumpWidget(
        host(child: const AdminUserListScreen(), repository: repository),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'keeper');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(repository.searches, contains('keeper'));
      expect(find.text('Administrator'), findsNothing);
    });

    testWidgets('a row opens the detail route', (tester) async {
      var opened = 0;
      await tester.pumpWidget(
        host(
          child: AdminUserListScreen(onOpenUser: (_, id) => opened = id),
          repository: FakeIdentityRepository(userRows: const [_keeper]),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Anbardar Kamil'));
      await tester.pumpAndSettle();
      expect(opened, 7);
    });

    testWidgets('without iam.user.manage nothing is listed', (tester) async {
      await tester.pumpWidget(
        host(
          child: const AdminUserListScreen(),
          repository: FakeIdentityRepository(userRows: const [_keeper]),
          permissions: const {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bu bölmə üçün icazəniz yoxdur'), findsOneWidget);
      expect(find.text('keeper'), findsNothing);
    });

    testWidgets('a server problem is shown with its code', (tester) async {
      await tester.pumpWidget(
        host(
          child: const AdminUserListScreen(),
          repository: FakeIdentityRepository(
            failure: ForbiddenFailure(
              ProblemDetails.local(
                code: ProblemCodes.forbidden,
                title: 'İcazə yoxdur',
                status: 403,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WmsAlert), findsOneWidget);
      expect(find.textContaining(ProblemCodes.forbidden), findsOneWidget);
    });
  });

  group('AdminUserDetailScreen', () {
    testWidgets('shows the Keycloak subject, roles and row version', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          child: const AdminUserDetailScreen(userId: 7),
          repository: FakeIdentityRepository(userRows: const [_keeper]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('kc-sub-7'), findsOneWidget);
      expect(find.text('WAREHOUSE_KEEPER'), findsOneWidget);
      expect(find.text('3, 4'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('+994 50 000 00 00'), findsOneWidget);
    });

    testWidgets('an unrestricted user is named as such', (tester) async {
      await tester.pumpWidget(
        host(
          child: const AdminUserDetailScreen(userId: 1),
          repository: FakeIdentityRepository(userRows: const [_admin]),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Məhdudiyyət yoxdur — bütün lokasiyalar'),
        findsOneWidget,
      );
      expect(find.text('Deaktiv'), findsOneWidget);
    });
  });

  group('AdminRoleListScreen', () {
    testWidgets('flags roles that carry critical permissions', (tester) async {
      await tester.pumpWidget(
        host(
          child: const AdminRoleListScreen(),
          repository: FakeIdentityRepository(
            roleRows: const [_adminRole, _keeperRole],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ADMIN'), findsOneWidget);
      expect(find.text('Anbardar'), findsOneWidget);
      expect(find.text('Sistem'), findsNWidgets(2));
      // ADMIN holds view_cost and po.approve, the keeper none.
      expect(find.text('2 kritik'), findsOneWidget);
    });

    test('critical permission detection follows SPEC §7.1', () {
      expect(AdminRoleListScreen.criticalCount(_adminRole), 2);
      expect(AdminRoleListScreen.criticalCount(_keeperRole), 0);
      expect(
        AdminRoleListScreen.criticalPermissions(_adminRole),
        containsAll(<String>[
          Permissions.productViewCost,
          Permissions.poApprove,
        ]),
      );
      expect(
        AdminRoleListScreen.criticalCodes,
        contains(Permissions.movementReverse),
      );
    });

    testWidgets('a row opens the role detail', (tester) async {
      var opened = 0;
      await tester.pumpWidget(
        host(
          child: AdminRoleListScreen(onOpenRole: (_, id) => opened = id),
          repository: FakeIdentityRepository(roleRows: const [_adminRole]),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Administrator'));
      await tester.pumpAndSettle();
      expect(opened, 1);
    });
  });

  group('AdminRoleDetailScreen', () {
    testWidgets('groups permissions by module and marks the critical ones', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          child: const AdminRoleDetailScreen(roleId: 1),
          repository: FakeIdentityRepository(
            roleRows: const [_adminRole],
            permissionRows: const [
              PermissionDto(
                id: 1,
                code: Permissions.productViewCost,
                module: 'masterdata',
                description: 'Maya dəyərini görmək',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('iam'), findsOneWidget);
      expect(find.text('master'), findsOneWidget);
      expect(find.text('proc'), findsOneWidget);
      expect(find.text('inv'), findsOneWidget);
      expect(find.text(Permissions.productViewCost), findsOneWidget);
    });

    testWidgets('a role without permissions explains the next step', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          child: const AdminRoleDetailScreen(roleId: 3),
          repository: FakeIdentityRepository(
            roleRows: const [
              RoleDto(id: 3, code: 'CUSTOM', name: 'Xüsusi rol'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WmsEmptyState), findsOneWidget);
      expect(find.text('Bu rola icazə bağlanmayıb.'), findsOneWidget);
    });

    test('grouping is sorted and keeps the wire codes', () {
      final grouped = AdminRoleDetailScreen.groupByModule(const [
        'proc.po.approve',
        'inv.receipt.create',
        'inv.balance.view',
        'weird',
      ]);
      expect(grouped.keys, containsAll(<String>['inv', 'proc', 'digər']));
      expect(grouped['inv'], ['inv.balance.view', 'inv.receipt.create']);
      expect(grouped['digər'], ['weird']);
    });
  });

  group('UserDto helpers', () {
    test('roleCodes and location restriction', () {
      expect(_keeper.roleCodes, 'WAREHOUSE_KEEPER');
      expect(_keeper.hasAllLocations, isFalse);
      expect(_admin.hasAllLocations, isTrue);
      expect(_keeper.rowVersion, 4);
      expect(_admin.rowVersion, 1, reason: 'defaults when audit is absent');
    });
  });
}
