import 'package:test/test.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';


/// tests for SupplierApprovalAdminApi
void main() {
  final instance = TalbatiykApi().getSupplierApprovalAdminApi();

  group(SupplierApprovalAdminApi, () {
    // Approve exactly one pending supplier application
    //
    //Future<SupplierApprovalAdminApprove200Response> supplierApprovalAdminApprove(String verification, { SupplierApprovalAdminApproveRequest supplierApprovalAdminApproveRequest }) async
    test('test supplierApprovalAdminApprove', () async {
      // TODO
    });

    // List pending supplier applications for authorized platform staff
    //
    //Future<SupplierApprovalAdminIndex200Response> supplierApprovalAdminIndex({ int perPage }) async
    test('test supplierApprovalAdminIndex', () async {
      // TODO
    });

    // Reject exactly one pending supplier application. A meaningful reason is mandatory
    //
    //Future<SupplierApprovalAdminApprove200Response> supplierApprovalAdminReject(String verification, SupplierApprovalAdminRejectRequest supplierApprovalAdminRejectRequest) async
    test('test supplierApprovalAdminReject', () async {
      // TODO
    });

  });
}
