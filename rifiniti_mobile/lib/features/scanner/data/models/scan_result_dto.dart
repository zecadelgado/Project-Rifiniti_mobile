import '../../domain/entities/scan_result.dart';

/// Data Transfer Object for scan result.
class ScanResultDto {
  final String code;
  final String type;
  final String scannedAt;

  const ScanResultDto({
    required this.code,
    required this.type,
    required this.scannedAt,
  });

  /// Create from JSON map.
  factory ScanResultDto.fromJson(Map<String, dynamic> json) {
    return ScanResultDto(
      code: json['code'] as String? ?? '',
      type: json['type'] as String? ?? 'unknown',
      scannedAt: json['scanned_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() => {
        'code': code,
        'type': type,
        'scanned_at': scannedAt,
      };

  /// Convert to domain entity.
  ScanResult toEntity() => ScanResult(
        code: code,
        type: _parseType(type),
        scannedAt: DateTime.tryParse(scannedAt) ?? DateTime.now(),
      );

  /// Parse scan type from string.
  static ScanType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'barcode':
        return ScanType.barcode;
      case 'qrcode':
      case 'qr_code':
        return ScanType.qrCode;
      default:
        return ScanType.unknown;
    }
  }
}
