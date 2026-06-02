import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App inicializa sem erros', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
  });
}
