import 'package:flutter/material.dart';

import '../services/profile_store.dart';
import '../services/saju_calculator.dart';
import 'saju_profile.dart';

class ProfileState extends ChangeNotifier {
  final ProfileStore _store;
  ProfileState(this._store);

  SajuProfile? profile;
  bool isLoaded = false;

  bool get hasProfile => profile != null;

  Future<void> load() async {
    profile = await _store.load();
    isLoaded = true;
    notifyListeners();
  }

  Future<void> calculateAndSave({
    required DateTime birthDateTime,
    required bool isLunar,
    bool isLeapMonth = false,
    required bool timeUnknown,
    required String birthCityName,
    required double birthLongitude,
  }) async {
    final result = SajuCalculator.calculate(
      birthDateTime: birthDateTime,
      isLunar: isLunar,
      isLeapMonth: isLeapMonth,
      timeUnknown: timeUnknown,
      birthCityName: birthCityName,
      birthLongitude: birthLongitude,
    );
    profile = result;
    notifyListeners();
    await _store.save(result);
  }

  Future<void> clear() async {
    profile = null;
    notifyListeners();
    await _store.clear();
  }
}
