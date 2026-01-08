import '../../domain/entities/asset.dart';

/// Data Transfer Object for Asset.
class AssetDto {
  final int id;
  final String code;
  final String name;
  final String? description;
  final String? serialNumber;
  final String? category;
  final String status;
  final int? sectorId;
  final String? sectorName;
  final int? locationId;
  final String? locationName;
  final String? acquisitionDate;
  final double? purchaseValue;
  final double? currentValue;
  final int? supplierId;
  final String? supplierName;
  final int? invoiceId;
  final String? invoiceNumber;
  final int? quantity;

  const AssetDto({
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

  /// Create from JSON map.
  /// Handles both API response format and desktop database format.
  factory AssetDto.fromJson(Map<String, dynamic> json) {
    return AssetDto(
      id: json['id'] as int? ??
          json['id_patrimonio'] as int? ??
          0,
      code: json['code'] as String? ??
          json['numero_patrimonial'] as String? ??
          '',
      name: json['name'] as String? ??
          json['nome'] as String? ??
          '',
      description: json['description'] as String? ??
          json['descricao'] as String?,
      serialNumber: json['serial_number'] as String? ??
          json['numero_serie'] as String?,
      category: json['category'] as String? ??
          json['categoria'] as String?,
      status: json['status'] as String? ?? 'ativo',
      sectorId: json['sector_id'] as int? ??
          json['id_setor'] as int?,
      sectorName: json['sector_name'] as String? ??
          json['setor_nome'] as String?,
      locationId: json['location_id'] as int? ??
          json['id_local'] as int?,
      locationName: json['location_name'] as String? ??
          json['local_nome'] as String?,
      acquisitionDate: json['acquisition_date'] as String? ??
          json['data_aquisicao'] as String?,
      purchaseValue: _parseDouble(json['purchase_value'] ?? json['valor_compra']),
      currentValue: _parseDouble(json['current_value'] ?? json['valor_atual']),
      supplierId: json['supplier_id'] as int? ??
          json['id_fornecedor'] as int?,
      supplierName: json['supplier_name'] as String? ??
          json['fornecedor_nome'] as String?,
      invoiceId: json['invoice_id'] as int? ??
          json['id_nota_fiscal'] as int?,
      invoiceNumber: json['invoice_number'] as String? ??
          json['numero_nota'] as String?,
      quantity: json['quantity'] as int? ??
          json['quantidade'] as int?,
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'description': description,
        'serial_number': serialNumber,
        'category': category,
        'status': status,
        'sector_id': sectorId,
        'sector_name': sectorName,
        'location_id': locationId,
        'location_name': locationName,
        'acquisition_date': acquisitionDate,
        'purchase_value': purchaseValue,
        'current_value': currentValue,
        'supplier_id': supplierId,
        'supplier_name': supplierName,
        'invoice_id': invoiceId,
        'invoice_number': invoiceNumber,
        'quantity': quantity,
      };

  /// Convert to domain entity.
  Asset toEntity() => Asset(
        id: id,
        code: code,
        name: name,
        description: description,
        serialNumber: serialNumber,
        category: category,
        status: status,
        sectorId: sectorId,
        sectorName: sectorName,
        locationId: locationId,
        locationName: locationName,
        acquisitionDate: acquisitionDate != null
            ? DateTime.tryParse(acquisitionDate!)
            : null,
        purchaseValue: purchaseValue,
        currentValue: currentValue,
        supplierId: supplierId,
        supplierName: supplierName,
        invoiceId: invoiceId,
        invoiceNumber: invoiceNumber,
        quantity: quantity,
      );

  /// Helper to parse double from various types.
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
