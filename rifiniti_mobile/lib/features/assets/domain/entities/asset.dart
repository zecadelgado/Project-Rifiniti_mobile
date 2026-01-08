/// Asset (Patrimônio) entity.
/// Represents a physical asset in the inventory system.
class Asset {
  final int id;
  final String code; // Número patrimonial
  final String name;
  final String? description;
  final String? serialNumber;
  final String? category;
  final String status;
  final int? sectorId;
  final String? sectorName;
  final int? locationId;
  final String? locationName;
  final DateTime? acquisitionDate;
  final double? purchaseValue;
  final double? currentValue;
  final int? supplierId;
  final String? supplierName;
  final int? invoiceId;
  final String? invoiceNumber;
  final int? quantity;

  const Asset({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.serialNumber,
    this.category,
    required this.status,
    this.sectorId,
    this.sectorName,
    this.locationId,
    this.locationName,
    this.acquisitionDate,
    this.purchaseValue,
    this.currentValue,
    this.supplierId,
    this.supplierName,
    this.invoiceId,
    this.invoiceNumber,
    this.quantity,
  });

  /// Check if asset is active.
  bool get isActive => status.toLowerCase() == 'ativo';

  /// Check if asset is in maintenance.
  bool get isInMaintenance =>
      status.toLowerCase() == 'em_manutencao' ||
      status.toLowerCase() == 'em manutencao';

  /// Check if asset is missing.
  bool get isMissing => status.toLowerCase() == 'desaparecido';

  /// Check if asset is inactive/baixado.
  bool get isInactive => status.toLowerCase() == 'baixado';

  /// Get full location string.
  String get fullLocation {
    final parts = <String>[];
    if (sectorName != null) parts.add(sectorName!);
    if (locationName != null) parts.add(locationName!);
    return parts.isEmpty ? '-' : parts.join(' / ');
  }

  /// Create a copy with updated fields.
  Asset copyWith({
    int? id,
    String? code,
    String? name,
    String? description,
    String? serialNumber,
    String? category,
    String? status,
    int? sectorId,
    String? sectorName,
    int? locationId,
    String? locationName,
    DateTime? acquisitionDate,
    double? purchaseValue,
    double? currentValue,
    int? supplierId,
    String? supplierName,
    int? invoiceId,
    String? invoiceNumber,
    int? quantity,
  }) {
    return Asset(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      serialNumber: serialNumber ?? this.serialNumber,
      category: category ?? this.category,
      status: status ?? this.status,
      sectorId: sectorId ?? this.sectorId,
      sectorName: sectorName ?? this.sectorName,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      purchaseValue: purchaseValue ?? this.purchaseValue,
      currentValue: currentValue ?? this.currentValue,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      invoiceId: invoiceId ?? this.invoiceId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() => 'Asset(id: $id, code: $code, name: $name, status: $status)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Asset && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
