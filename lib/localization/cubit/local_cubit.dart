import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class LocaleCubit extends Cubit<Locale> {
  final Box _box = Hive.box('users_box');

  LocaleCubit() : super(const Locale('en')) {
    getSavedLanguage();
  }

  void changeLanguage(String languageCode) async {
    await _box.put('selected_language', languageCode);
    emit(Locale(languageCode));
  }


  void getSavedLanguage() {
    final String cachedLanguageCode = _box.get('selected_language', defaultValue: 'en');
    emit(Locale(cachedLanguageCode));
  }
}