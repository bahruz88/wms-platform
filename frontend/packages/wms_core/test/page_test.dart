import 'package:test/test.dart';
import 'package:wms_core/wms_core.dart';

void main() {
  test('Page parses spec envelope and computes paging', () {
    final page = Page<Quantity>.fromJson(const {
      'items': ['1.5', '2'],
      'page': 2,
      'size': 50,
      'total': 1284,
    }, (e) => Quantity.fromJson(e! as String));
    expect(page.items, hasLength(2));
    expect(page.totalPages, 26);
    expect(page.hasNext, isTrue);
    expect(page.hasPrevious, isTrue);
    expect(page.map((q) => q.toJson()).items, ['1.5000', '2.0000']);
    expect(const Page<int>.empty().totalPages, 0);
  });

  test('PageRequest enforces limits', () {
    expect(const PageRequest(page: 3).next().page, 4);
    expect(const PageRequest().toQuery(), {'page': 1, 'size': 50});
  });

  test('enums expose wire values matching the spec', () {
    expect(DocType.fromWire('COUNT_ADJUST'), DocType.countAdjust);
    expect(DocType.receipt.numberPrefix, 'GR');
    expect(LocationType.inTransit.isVirtual, isTrue);
    expect(LocationType.restaurant.isVirtual, isFalse);
    expect(PoStatus.pendingApproval.canApprove, isTrue);
    expect(CountStatus.frozen.blocksLocation, isTrue);
    expect(IssueStatus.dispatched.isInTransit, isTrue);
    expect(BatchStatus.blocked.isAllocatable, isFalse);
    expect(ReasonGroup.fromWire('RETURN'), ReasonGroup.returnToVendor);
    expect(Permissions.all, contains(Permissions.productViewCost));
    expect(Permissions.poApprove, 'proc.po.approve');
  });
}
