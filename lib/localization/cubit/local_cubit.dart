import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class LocaleCubit extends Cubit<Locale> {
  // بنفتح الـ Box اللي إنتِ معرفاه في الـ main
  final Box _box = Hive.box('users_box');

  LocaleCubit() : super(const Locale('en')) {
    getSavedLanguage();
  }

  // دالة تغيير اللغة وحفظها في هايف
  void changeLanguage(String languageCode) async {
    await _box.put('selected_language', languageCode);
    emit(Locale(languageCode));
  }

  // دالة استرجاع اللغة عند تشغيل التطبيق
  void getSavedLanguage() {
    // بنقرأ اللغة المخزنة، ولو مفيش بنخلي الافتراضي إنجليزي 'en'
    final String cachedLanguageCode = _box.get('selected_language', defaultValue: 'en');
    emit(Locale(cachedLanguageCode));
  }
}