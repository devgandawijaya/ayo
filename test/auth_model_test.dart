import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ayo_app/models/login_response.dart';

void main() {
  const sampleApiResponse = '''{
    "status_code": 1,
    "message": "login success",
    "data": {
        "id": 474,
        "master_person_id": 480,
        "master_company_id": 1,
        "master_role_id": 2,
        "name": "TATANG ROSWANDI GANDA WIJAYA",
        "email": "tatang@pkp.co.id",
        "deleted_at": null,
        "created_at": null,
        "updated_at": "2026-03-18T05:02:09.000000Z",
        "created_by": 7,
        "updated_by": 7,
        "deleted_by": null,
        "fcm_token": "cFKnK-bzQIW498i55ntnof",
        "avatar": null,
        "roles": [
            {
                "id": 2,
                "name": "Employee",
                "display_name": "Employee",
                "description": "Employee"
            }
        ],
        "configuration": {
            "id": 1,
            "selfie": true,
            "geotaging": true,
            "radius": "150",
            "fingerprint": false,
            "session_timeout": 300
        },
        "token": "sample_jwt_token_123",
        "employee": {
            "id": 470,
            "npk": "L261074",
            "join_date": "2026-01-26",
            "app_id": "3507398578724",
            "spv_id": 12,
            "department_id": 6
        },
        "company": {
            "id": 1,
            "name": "PT. PKP",
            "description": "Prawathiya Karsa Pradiptha",
            "is_active": true
        },
        "person": {
            "id": 480,
            "name": "TATANG ROSWANDI GANDA WIJAYA",
            "marital_status": "Menikah",
            "religion": "Islam",
            "gender": "Laki-Laki"
        }
    }
}''';

  test('LoginResponse correctly parses server JSON payload', () {
    final Map<String, dynamic> jsonMap = jsonDecode(sampleApiResponse);
    final response = LoginResponse.fromJson(jsonMap);

    expect(response.isSuccess, true);
    expect(response.message, 'login success');
    expect(response.data?.name, 'TATANG ROSWANDI GANDA WIJAYA');
    expect(response.data?.token, 'sample_jwt_token_123');
    expect(response.data?.employee?.npk, 'L261074');
    expect(response.data?.company?.name, 'PT. PKP');
    expect(response.data?.configuration?.selfie, true);
    expect(response.data?.configuration?.geotagging, true);
    expect(response.data?.configuration?.radius, '150');
    expect(response.data?.person?.gender, 'Laki-Laki');
    expect(response.data?.roles.first.name, 'Employee');
  });
}
