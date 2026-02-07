import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zard/zard.dart';

class FieldValidationHandler {
  final Map<String, String?> _apiErrorMap = {};
  final Map<String, Schema?> fields;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FieldValidationHandler({required this.fields}) {
    _generateFields();
  }

  void _generateFields() {
    for (var fieldName in fields.keys) {
      _apiErrorMap[fieldName] = null;
    }
  }

  String? validate(String field, String? value) {
    final schema = fields[field];

    if (schema != null) {
      final trimmedValue = (value ?? '').trim();
      final result = schema.safeParse(
        trimmedValue.isEmpty ? null : trimmedValue,
      );

      if (!result.success) {
        return result.error?.messages;
      }
    }

    final apiError = _apiErrorMap[field];
    if (apiError != null) {
      return apiError;
    }

    return null;
  }

  void clearAllErrors() {
    _apiErrorMap.updateAll((key, value) => null);
  }

  void clearError(String field) {
    if (_apiErrorMap.containsKey(field)) {
      _apiErrorMap[field] = null;
    }
  }

  void setFieldMapErrors(Object dioException) {
    clearAllErrors();
    if (dioException is DioException) {
      final resp = dioException.response;
      if (resp?.data is Map<String, dynamic>) {
        final data = resp!.data as Map<String, dynamic>;
        final inner = data['data'] as Map<String, dynamic>? ?? {};
        final errors = inner['errors'] as Map<String, dynamic>? ?? {};
        errors.forEach((name, msgs) {
          if (msgs is List && _apiErrorMap.containsKey(name)) {
            _apiErrorMap[name] = msgs.whereType<String>().join(' ');
          }
        });
      }
      formKey.currentState?.validate();
    }
  }
}
