import 'package:dio/dio.dart';

import '../../../../core/config/endpoints.dart';
import '../../../../core/config/env.dart';
import '../../../../core/network/dio_client.dart';
import '../models/asset_dto.dart';

/// Remote data source for assets.
abstract class AssetsRemoteDataSource {
  /// Get asset by ID.
  Future<AssetDto> getAssetById(int id);

  /// Get asset by code.
  Future<AssetDto> getAssetByCode(String code);

  /// Get list of assets.
  Future<List<AssetDto>> getAssets({
    int? limit,
    int? offset,
    String? search,
    String? category,
    String? status,
    int? sectorId,
  });

  /// Get total count of assets.
  Future<int> getAssetsCount({
    String? search,
    String? category,
    String? status,
    int? sectorId,
  });
}

/// Implementation of [AssetsRemoteDataSource].
class AssetsRemoteDataSourceImpl implements AssetsRemoteDataSource {
  final DioClient _client;

  AssetsRemoteDataSourceImpl(this._client);

  @override
  Future<AssetDto> getAssetById(int id) async {
    if (!Env.isApiConfigured) {
      return _mockGetAssetById(id);
    }

    try {
      final response = await _client.get<Map<String, dynamic>>(
        Endpoints.assetById(id),
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Empty response',
        );
      }

      return AssetDto.fromJson(response.data!);
    } on DioException {
      if (Env.isDev) {
        return _mockGetAssetById(id);
      }
      rethrow;
    }
  }

  @override
  Future<AssetDto> getAssetByCode(String code) async {
    if (!Env.isApiConfigured) {
      return _mockGetAssetByCode(code);
    }

    try {
      final response = await _client.get<Map<String, dynamic>>(
        Endpoints.assetByBarcode(code),
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Empty response',
        );
      }

      return AssetDto.fromJson(response.data!);
    } on DioException {
      if (Env.isDev) {
        return _mockGetAssetByCode(code);
      }
      rethrow;
    }
  }

  @override
  Future<List<AssetDto>> getAssets({
    int? limit,
    int? offset,
    String? search,
    String? category,
    String? status,
    int? sectorId,
  }) async {
    if (!Env.isApiConfigured) {
      return _mockGetAssets();
    }

    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null) queryParams['category'] = category;
      if (status != null) queryParams['status'] = status;
      if (sectorId != null) queryParams['sector_id'] = sectorId;

      final response = await _client.get<Map<String, dynamic>>(
        Endpoints.assets,
        queryParameters: queryParams,
      );

      if (response.data == null) {
        return [];
      }

      final data = response.data!['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => AssetDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      if (Env.isDev) {
        return _mockGetAssets();
      }
      rethrow;
    }
  }

  @override
  Future<int> getAssetsCount({
    String? search,
    String? category,
    String? status,
    int? sectorId,
  }) async {
    if (!Env.isApiConfigured) {
      return 10; // Mock count
    }

    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null) queryParams['category'] = category;
      if (status != null) queryParams['status'] = status;
      if (sectorId != null) queryParams['sector_id'] = sectorId;

      final response = await _client.get<Map<String, dynamic>>(
        Endpoints.assets,
        queryParameters: {...queryParams, 'limit': 1},
      );

      return response.data?['total'] as int? ?? 0;
    } on DioException {
      if (Env.isDev) {
        return 10;
      }
      rethrow;
    }
  }

  // ============================================================
  // MOCK DATA
  // ============================================================

  Future<AssetDto> _mockGetAssetById(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final assets = await _mockGetAssets();
    return assets.firstWhere(
      (a) => a.id == id,
      orElse: () => assets.first,
    );
  }

  Future<AssetDto> _mockGetAssetByCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final assets = await _mockGetAssets();
    return assets.firstWhere(
      (a) => a.code == code,
      orElse: () => AssetDto(
        id: code.hashCode,
        code: code,
        name: 'Ativo $code',
        status: 'ativo',
      ),
    );
  }

  Future<List<AssetDto>> _mockGetAssets() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const AssetDto(
        id: 1,
        code: '123456',
        name: 'Notebook Dell Latitude',
        description: 'Notebook Dell Latitude 5520',
        serialNumber: 'DELL-2024-001',
        category: 'Eletronico',
        status: 'ativo',
        sectorId: 1,
        sectorName: 'TI',
        locationId: 1,
        locationName: 'Sala 101',
        acquisitionDate: '2024-01-15',
        purchaseValue: 5500.00,
        currentValue: 4950.00,
      ),
      const AssetDto(
        id: 2,
        code: '789012',
        name: 'Monitor LG 27"',
        description: 'Monitor LG UltraWide 27"',
        category: 'Eletronico',
        status: 'ativo',
        sectorId: 1,
        sectorName: 'TI',
        locationId: 1,
        locationName: 'Sala 101',
        acquisitionDate: '2024-02-20',
        purchaseValue: 1800.00,
        currentValue: 1620.00,
      ),
      const AssetDto(
        id: 3,
        code: '345678',
        name: 'Cadeira Ergonômica',
        category: 'Movel',
        status: 'em_manutencao',
        sectorId: 2,
        sectorName: 'Administrativo',
        locationId: 3,
        locationName: 'Sala 201',
        acquisitionDate: '2023-06-10',
        purchaseValue: 1200.00,
        currentValue: 960.00,
      ),
      const AssetDto(
        id: 4,
        code: '901234',
        name: 'Impressora HP LaserJet',
        category: 'Eletronico',
        status: 'ativo',
        sectorId: 2,
        sectorName: 'Administrativo',
        locationId: 2,
        locationName: 'Recepção',
        acquisitionDate: '2023-03-05',
        purchaseValue: 2500.00,
        currentValue: 2000.00,
      ),
      const AssetDto(
        id: 5,
        code: '567890',
        name: 'Mesa de Escritório',
        category: 'Movel',
        status: 'baixado',
        sectorId: 3,
        sectorName: 'RH',
        locationId: 4,
        locationName: 'Sala 301',
        acquisitionDate: '2020-01-10',
        purchaseValue: 800.00,
        currentValue: 200.00,
      ),
    ];
  }
}
