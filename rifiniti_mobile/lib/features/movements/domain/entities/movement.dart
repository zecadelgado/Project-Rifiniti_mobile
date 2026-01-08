/// Movement (Movimentação) entity.
/// Represents a movement/transfer of an asset.
class Movement {
  final int id;
  final int assetId;
  final String? assetCode;
  final String? assetName;
  final MovementType type;
  final DateTime date;
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
  final DateTime? createdAt;

  const Movement({
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

  /// Get origin full location.
  String get originLocation {
    final parts = <String>[];
    if (originSectorName != null) parts.add(originSectorName!);
    if (originLocationName != null) parts.add(originLocationName!);
    return parts.isEmpty ? '-' : parts.join(' / ');
  }

  /// Get destination full location.
  String get destinationLocation {
    final parts = <String>[];
    if (destinationSectorName != null) parts.add(destinationSectorName!);
    if (destinationLocationName != null) parts.add(destinationLocationName!);
    return parts.isEmpty ? '-' : parts.join(' / ');
  }

  @override
  String toString() =>
      'Movement(id: $id, assetId: $assetId, type: $type, date: $date)';
}

/// Movement type enum.
enum MovementType {
  transfer,
  loan,
  returnItem,
  maintenance,
}

/// Extension for MovementType.
extension MovementTypeExtension on MovementType {
  String get displayName {
    switch (this) {
      case MovementType.transfer:
        return 'Transferência';
      case MovementType.loan:
        return 'Empréstimo';
      case MovementType.returnItem:
        return 'Devolução';
      case MovementType.maintenance:
        return 'Manutenção';
    }
  }

  String get value {
    switch (this) {
      case MovementType.transfer:
        return 'transferencia';
      case MovementType.loan:
        return 'emprestimo';
      case MovementType.returnItem:
        return 'devolucao';
      case MovementType.maintenance:
        return 'manutencao';
    }
  }

  static MovementType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'transferencia':
      case 'transfer':
        return MovementType.transfer;
      case 'emprestimo':
      case 'loan':
        return MovementType.loan;
      case 'devolucao':
      case 'return':
        return MovementType.returnItem;
      case 'manutencao':
      case 'maintenance':
        return MovementType.maintenance;
      default:
        return MovementType.transfer;
    }
  }
}
