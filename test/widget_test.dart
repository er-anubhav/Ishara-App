import 'package:docuhealth/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('VPS API config smoke test', () {
    expect(baseUrl, isNotEmpty);
    expect(baseUrl.contains('/api/v1/'), isTrue);
  });
}
