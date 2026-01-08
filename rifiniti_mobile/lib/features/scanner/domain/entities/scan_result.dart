/// Scan result entity representing a scanned barcode/QR code.
class ScanResult {
  final String code;
  final ScanType type;
  final DateTime scannedAt;

  const ScanResult({
    required this.code,
    required this.type,
    required this.scannedAt,
  });

  @override
  String toString() => 'ScanResult(code: $code, type: $type)';
}

/// Type of scanned code.
enum ScanType {
  barcode,
  qrCode,
  unknown,
}

/// Extension to get display name for scan type.
extension ScanTypeExtension on ScanType {
  String get displayName {
    switch (this) {
      case ScanType.barcode:
        return 'Código de Barras';
      case ScanType.qrCode:
        return 'QR Code';
      case ScanType.unknown:
        return 'Desconhecido';
    }
  }
}
