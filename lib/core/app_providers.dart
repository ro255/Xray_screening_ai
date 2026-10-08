import 'package:diesease_ai_app/core/api_client.dart';
import 'package:diesease_ai_app/core/app_language.dart';
import 'package:diesease_ai_app/core/setting.dart';
import 'package:diesease_ai_app/feature/xray/xray_model.dart';
import 'package:diesease_ai_app/feature/xray/xray_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

Widget withAppProviders({
  required Settings settings,
  required AppLanguageController languageController,
  required Widget child,
}) {
  return MultiProvider(
    providers: [
      Provider<Settings>.value(value: settings),
      ChangeNotifierProvider<AppLanguageController>.value(
        value: languageController,
      ),
      Provider<Dio>(
        create: (context) => createDio(context.read<Settings>()),
      ),
      Provider<XrayRepository>(
        create: (context) => XrayRepository(
          context.read<Dio>(),
          context.read<Settings>(),
        ),
      ),
      Provider<Future<HealthStatus>>(
        create: (context) => context.read<XrayRepository>().healthCheck(),
      ),
    ],
    child: child,
  );
}
