// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '路邊停車';

  @override
  String get statusIdle => '閒置中';

  @override
  String get statusDriving => '駕駛中';

  @override
  String get statusVerifying => '驗證位置中...';

  @override
  String get statusParked => '已停車';

  @override
  String get statusLeaving => '駛離車位';

  @override
  String get currentStatus => '目前狀態：';

  @override
  String get manualTesting => '手動測試覆寫';

  @override
  String get simulateDriving => '模擬駕駛';

  @override
  String get simulateStop => '模擬停車';

  @override
  String get confirmParked => '確認已停車';

  @override
  String get simulateDeparture => '模擬駛離';

  @override
  String parkedAt(String street) {
    return '停車地點：$street';
  }

  @override
  String time(String time) {
    return '時間：$time';
  }
}
