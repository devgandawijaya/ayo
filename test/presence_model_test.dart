import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ayo_app/models/presence_response.dart';

void main() {
  const samplePresencePayload = '''{
    "status_code": 1,
    "message": "ok",
    "data": {
        "page_size": "1000",
        "total": 1,
        "page": 1,
        "data": [
            {
                "id": 194585,
                "master_company_id": 1,
                "master_employee_id": 470,
                "time_in_location_id": 1,
                "time_out_location_id": 1,
                "latitude": "-6.3813045",
                "longitude": "106.9260342",
                "radius": "32",
                "time_in": "08:57:00",
                "time_out": "23:39:00",
                "deleted_at": null,
                "created_at": "2026-11-06 08:57:14",
                "updated_at": "2026-11-06 22:16:05",
                "late": -26,
                "start_break": "12:00:00",
                "end_break": "13:00:00",
                "reason": "telat",
                "setup_time_in": "08:00:00",
                "setup_time_in_dl": "08:31:00",
                "mobile_id": "a61185d4-f3fb-4b29-a976-e6a37f5c30ef",
                "time_in_location": {
                    "id": 1,
                    "name": "PKP HO",
                    "latitude": "-6.3815720254506",
                    "longitude": "106.92583590746"
                }
            }
        ]
    }
}''';

  test('PresenceResponse correctly parses presences JSON', () {
    final Map<String, dynamic> jsonMap = jsonDecode(samplePresencePayload);
    final response = PresenceResponse.fromJson(jsonMap);

    expect(response.isSuccess, true);
    expect(response.total, 1);
    expect(response.presences.length, 1);

    final presence = response.presences.first;
    expect(presence.id, 194585);
    expect(presence.timeIn, '08:57:00');
    expect(presence.timeOut, '23:39:00');
    expect(presence.isLate, true);
    expect(presence.lateMinutes, 26);
    expect(presence.reason, 'telat');
    expect(presence.timeInLocation?.name, 'PKP HO');
    expect(presence.radius, '32');
  });
}
