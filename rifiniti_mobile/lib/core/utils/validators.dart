/// Validation utilities for form fields.
abstract class Validators {
  /// Email regex pattern.
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validate email format.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-mail é obrigatório';
    }

    if (!_emailRegex.hasMatch(value)) {
      return 'E-mail inválido';
    }

    return null;
  }

  /// Validate password.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }

    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }

    return null;
  }

  /// Validate required field.
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName é obrigatório' : 'Campo obrigatório';
    }
    return null;
  }

  /// Validate barcode/QR code.
  static String? validateBarcode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Código é obrigatório';
    }

    // Basic validation - at least 3 characters
    if (value.length < 3) {
      return 'Código deve ter pelo menos 3 caracteres';
    }

    return null;
  }

  /// Validate numeric value.
  static String? validateNumeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty for optional fields
    }

    if (double.tryParse(value) == null) {
      return fieldName != null
          ? '$fieldName deve ser um número válido'
          : 'Valor deve ser um número válido';
    }

    return null;
  }

  /// Validate positive number.
  static String? validatePositiveNumber(String? value, {String? fieldName}) {
    final numericError = validateNumeric(value, fieldName: fieldName);
    if (numericError != null) return numericError;

    if (value != null && value.isNotEmpty) {
      final number = double.parse(value);
      if (number <= 0) {
        return fieldName != null
            ? '$fieldName deve ser maior que zero'
            : 'Valor deve ser maior que zero';
      }
    }

    return null;
  }

  /// Validate date is not in the future.
  static String? validateNotFutureDate(DateTime? value, {String? fieldName}) {
    if (value == null) {
      return null; // Allow null for optional fields
    }

    if (value.isAfter(DateTime.now())) {
      return fieldName != null
          ? '$fieldName não pode ser no futuro'
          : 'Data não pode ser no futuro';
    }

    return null;
  }

  /// Validate minimum length.
  static String? validateMinLength(
    String? value, {
    required int minLength,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty for optional fields
    }

    if (value.length < minLength) {
      return fieldName != null
          ? '$fieldName deve ter pelo menos $minLength caracteres'
          : 'Deve ter pelo menos $minLength caracteres';
    }

    return null;
  }

  /// Validate maximum length.
  static String? validateMaxLength(
    String? value, {
    required int maxLength,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty for optional fields
    }

    if (value.length > maxLength) {
      return fieldName != null
          ? '$fieldName deve ter no máximo $maxLength caracteres'
          : 'Deve ter no máximo $maxLength caracteres';
    }

    return null;
  }

  /// Check if email is valid (returns bool).
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email);
  }

  /// Check if password is valid (returns bool).
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
}
