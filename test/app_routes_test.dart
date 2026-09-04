import 'package:flutter_test/flutter_test.dart';

import 'package:aner_astaner/core/routes/app_routes.dart';

void main() {
  test('registers the application routes', () {
    expect(
      AppRoutes.pages.keys,
      containsAll(<String>[
        AppRoutes.splash,
        AppRoutes.initialLogin,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.masterHome,
        AppRoutes.category,
      ]),
    );
  });
}
