import '../../domain/entities/movement.dart';

/// Data Transfer Object for Movement.
class MovementDto {
  final int id;
  final int assetId;
  final String? assetCode;
  final String? assetName;
  final String type;
  final String date;
  final int? originSectorId;
  final String? originSectorName;
  final int? originLocationId;
  final String? originLocationName;
  final int? destinationSectorId;
  final String? destinationSectorName;
  final int? destinationLocationId;
  final String? destinationLocationName;
  final String? responsible;
  final String? reason;
  final String? notes;
  final int? userId;
  final String? userName;
  final String? createdAt;

  const MovementDto({
    required this.id,
    required this.assetId,
    this.assetCode,
    this.assetName,
    required this.type,
    required this.date,
    this.originSectorId,
    this.originSectorName,
    this.originLocationId,
    this.originLocationName,
    this.destinationSectorId,
    this.destinationSectorName,
    this.destinationLocationId,
    this.destinationLocationName,
    this.responsible,
    this.reason,
    this.notes,
    this.userId,
    this.userName,
    this.createdAt,
  });

  /// Create from JSON map.
  factory MovementDto.fromJson(Map<String, dynamic> json) {
    return MovementDto(
      id: json['id'] as int? ?? json['id_movimentacao'] as int? ?? 0,
      assetId: json['asset_id'] as int? ?? json['id_patrimonio'] as int? ?? 0,
      assetCode: json['asset_code'] as String? ??
          json['numero_patrimonial'] as String?,
      assetName: json['asset_name'] as String? ??
          json['patrimonio_nome'] as String?,
      type: json['type'] as String? ?? json['tipo'] as String? ?? 'transferencia',
      date: json['date'] as String? ??
          json['data_movimentacao'] as String? ??
          DateTime.now().toIso8601String(),
      originSectorId: json['origin_sector_id'] as int? ??
          json['id_setor_origem'] as int?,
      originSectorName: json['origin_sector_name'] as String? ??
          json['setor_origem'] as String?,
      originLocationId: json['origin_location_id'] as int? ??
          json['id_local_origem'] as int?,
      originLocationName: json['origin_location_name'] as String? ??
          json['local_origem'] as String?,
      destinationSectorId: json['destination_sector_id'] as int? ??
          json['id_setor_destino'] as int?,
      destinationSectorName: json['destination_sector_name'] as String? ??
          json['setor_destino'] as String?,
      destinationLocationId: json['destination_location_id'] as int? ??
          json['id_local_destino'] as int?,
      destinationLocationName: json['destination_location_name'] as String? ??
          json['local_destino'] as String?,
      responsible: json['responsible'] as String? ??
          json['responsavel'] as String?,
      reason: json['reason'] as String? ?? json['motivo'] as String?,
      notes: json['notes'] as String? ?? json['observacoes'] as String?,
      userId: json['user_id'] as int? ?? json['id_usuario'] as int?,
      userName: json['user_name'] as String? ??
          json['usuario_nome'] as String?,
      createdAt: json['created_at'] as String? ??
          json['data_registro'] as String?,
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'asset_id': assetId,
        'asset_code': assetCode,
        'asset_name': assetName,
        'type': type,
        'date': date,
        'origin_sector_id': originSectorId,
        'origin_sector_name': originSectorName,
        'origin_location_id': originLocationId,
        'origin_location_name': originLocationName,
        'destination_sector_id': destinationSectorId,
        'destination_sector_name': destinationSectorName,
        'destination_location_id': destinationLocationId,
        'destination_location_name': destinationLocationName,
        'responsible': responsible,
        'reason': reason,
        'notes': notes,
        'user_id': userId,
        'user_name': userName,
        'created_at': createdAt,
      };

  /// Convert to domain entity.
  Movement toEntity() => Movement(
        id: id,
        assetId: assetId,
        assetCode: assetCode,
        assetName: assetName,
        type: MovementTypeExtension.fromString(type),
        date: DateTime.tryParse(date) ?? DateTime.now(),
        originSectorId: originSectorId,
        originSectorName: originSectorName,
        originLocationId: originLocationId,
        originLocationName: originLocationName,
        destinationSectorId: destinationSectorId,
        destinationSectorName: destinationSectorName,
        destinationLocationId: destinationLocationId,
        destinationLocationName: destinationLocationName,
        responsible: responsible,
        reason: reason,
        notes: notes,
        userId: userId,
        userName: userName,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      );
}

/// DTO for creating a new movement.
class CreateMovementDto {
  final int assetId;
  final String type;
  final String date;
  final int? destinationSectorId;
  final int? destinationLocationId;
  final String? responsible;
  final String? reason;
  final String? notes;

  const CreateMovementDto({
    required this.assetId,
    required this.type,
    required this.date,
    this.destinationSectorId,
    this.destinationLocationId,
    this.responsible,
    this.reason,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'asset_id': assetId,
        'type': type,
        'date': date,
        'destination_sector_id': destinationSectorId,
        'destination_location_id': destinationLocationId,
        'responsible': responsible,
        'reason': reason,
        'notes': notes,
      };
}
