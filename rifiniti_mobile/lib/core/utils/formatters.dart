import 'package:intl/intl.dart';

/// Formatting utilities for displaying data.
abstract class Formatters {
  // Date formatters
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final _timeFormat = DateFormat('HH:mm');
  static final _isoFormat = DateFormat('yyyy-MM-dd');

  // Currency formatter (Brazilian Real)
  static final _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  // Number formatter
  static final _numberFormat = NumberFormat.decimalPattern('pt_BR');

  // ============================================================
  // DATE FORMATTING
  // ============================================================

  /// Format date as dd/MM/yyyy.
  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    return _dateFormat.format(date);
  }

  /// Format date and time as dd/MM/yyyy HH:mm.
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return _dateTimeFormat.format(dateTime);
  }

  /// Format time as HH:mm.
  static String formatTime(DateTime? time) {
    if (time == null) return '-';
    return _timeFormat.format(time);
  }

  /// Format date as ISO string (yyyy-MM-dd).
  static String formatIsoDate(DateTime? date) {
    if (date == null) return '';
    return _isoFormat.format(date);
  }

  /// Parse date from dd/MM/yyyy string.
  static DateTime? parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return _dateFormat.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  /// Parse date from ISO string (yyyy-MM-dd).
  static DateTime? parseIsoDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  /// Format relative time (e.g., "há 5 minutos").
  static String formatRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return '-';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'há $years ${years == 1 ? 'ano' : 'anos'}';
    }

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'há $months ${months == 1 ? 'mês' : 'meses'}';
    }

    if (difference.inDays > 0) {
      return 'há ${difference.inDays} ${difference.inDays == 1 ? 'dia' : 'dias'}';
    }

    if (difference.inHours > 0) {
      return 'há ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    }

    if (difference.inMinutes > 0) {
      return 'há ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
    }

    return 'agora';
  }

  // ============================================================
  // CURRENCY FORMATTING
  // ============================================================

  /// Format value as Brazilian Real currency.
  static String formatCurrency(num? value) {
    if (value == null) return 'R\$ 0,00';
    return _currencyFormat.format(value);
  }

  /// Parse currency string to double.
  static double? parseCurrency(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      // Remove currency symbol and spaces
      final cleaned = value
          .replaceAll('R\$', '')
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      return double.parse(cleaned);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // NUMBER FORMATTING
  // ============================================================

  /// Format number with thousand separators.
  static String formatNumber(num? value) {
    if (value == null) return '0';
    return _numberFormat.format(value);
  }

  /// Format decimal number with specified precision.
  static String formatDecimal(num? value, {int decimalDigits = 2}) {
    if (value == null) return '0';
    return value.toStringAsFixed(decimalDigits);
  }

  // ============================================================
  // STATUS FORMATTING
  // ============================================================

  /// Format asset status to display text.
  static String formatStatus(String? status) {
    if (status == null || status.isEmpty) return '-';

    switch (status.toLowerCase()) {
      case 'ativo':
      case 'active':
        return 'Ativo';
      case 'baixado':
      case 'inactive':
        return 'Baixado';
      case 'em_manutencao':
      case 'em manutencao':
      case 'maintenance':
        return 'Em Manutenção';
      case 'desaparecido':
      case 'missing':
        return 'Desaparecido';
      default:
        return status;
    }
  }

  /// Format movement type to display text.
  static String formatMovementType(String? type) {
    if (type == null || type.isEmpty) return '-';

    switch (type.toLowerCase()) {
      case 'transferencia':
      case 'transfer':
        return 'Transferência';
      case 'emprestimo':
      case 'loan':
        return 'Empréstimo';
      case 'devolucao':
      case 'return':
        return 'Devolução';
      case 'manutencao':
      case 'maintenance':
        return 'Manutenção';
      default:
        return type;
    }
  }

  // ============================================================
  // TEXT FORMATTING
  // ============================================================

  /// Truncate text with ellipsis.
  static String truncate(String? text, {int maxLength = 50}) {
    if (text == null || text.isEmpty) return '-';
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Capitalize first letter.
  static String capitalize(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Format null or empty values with placeholder.
  static String formatOrPlaceholder(String? value, {String placeholder = '-'}) {
    if (value == null || value.trim().isEmpty) return placeholder;
    return value;
  }
}
