import 'dart:async';

import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:potato_center/internal/methods.dart';

class AppInfoProvider extends ChangeNotifier {
  AppInfoProvider() {
    loadData();
  }

  Brightness _systemBrightness = Brightness.light;
  bool _isDark = false;
  bool _isDeveloper = false;
  Color _accentColor = Colors.blue;
  int _splashMode = 0;
  int _devCounter = 0;
  PermissionStatus _storageStatus;

  Brightness get systemBrightness => _systemBrightness;

  bool get isDark => _isDark;

  bool get isDeveloper => _isDeveloper;

  int get splashMode => _splashMode;

  int get devCounter => _devCounter;

  PermissionStatus get storageStatus => _storageStatus;

  get accentColor => _accentColor;

  set systemBrightness(Brightness newBrightness) {
    _systemBrightness = newBrightness;
    notifyListeners();
  }

  set isDark(bool val) {
    _isDark = val;
    setDark(val);
    notifyListeners();
  }

  set isDeveloper(bool val) {
    _isDeveloper = val;
    setDeveloperMode(val);
    notifyListeners();
  }

  set accentColor(Color val) {
    _accentColor = val;
    notifyListeners();
  }

  set splashMode(int val) {
    _splashMode = val;
    notifyListeners();
  }

  set devCounter(int val) {
    _devCounter = val;
    if (val >= 10) {
      devCounter = 0;
      isDeveloper = true;
    }
    notifyListeners();
  }

  set storageStatus(PermissionStatus val) {
    _storageStatus = val;
    notifyListeners();
  }

  Future<void> updateMainColor() async {
    int sysAccent = systemBrightness == Brightness.dark
        ? await AndroidFlutterUpdater.getDarkAccentColor()
        : await AndroidFlutterUpdater.getLightAccentColor();

    accentColor = Color(sysAccent);
  }

  Future<void> loadData() async {
    systemBrightness = await AndroidFlutterUpdater.isCurrentThemeDark()
        ? Brightness.dark
        : Brightness.light;
    isDark = await getDark();
    isDeveloper = await getDeveloperMode();
    updateMainColor();
    storageStatus = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
  }
}
