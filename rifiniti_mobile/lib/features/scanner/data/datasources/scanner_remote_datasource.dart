import 'package:dio/dio.dart';

import '../../../../core/config/endpoints.dart';
import '../../../../core/config/env.dart';
import '../../../../core/network/dio_client.dart';
import '../../../assets/data/models/asset_dto.dart';

/// Remote data source for scanner operations.
abstract class ScannerRemoteDataSource {
  /// Fetch asset by barcode/QR code.
  Future<AssetDto> fetchItemByBarcode(String code);
}

/// Implementation of [ScannerRemoteDataSource].
class ScannerRemoteDataSourceImpl implements ScannerRemoteDataSource {
  final DioClient _client;

  ScannerRemoteDataSourceImpl(this._client);

  @override
  Future<AssetDto> fetchItemByBarcode(String code) async {
    // TODO: Connect to real Rifiniti Desk API when available
    if (!Env.isApiConfigured) {
      print('[ScannerRemoteDataSource] API not configured, using mock data');
      return _mockFetchByBarcode(code);
    }

    try {
      final response = await _client.get<Map<String, dynamic>>(
        Endpoints.assetByBarcode(code),
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Empty response from server',
        );
      }

      return AssetDto.fromJson(response.data!);
    } on DioException catch (e) {
      // If API fails and we're in dev, fallback to mock
      if (Env.isDev && e.response?.statusCode != 404) {
        print('[ScannerRemoteDataSource] API call failed, using mock fallback');
        return _mockFetchByBarcode(code);
      }
      rethrow;
    }
  }

  // ============================================================
  // MOCK DATA (for development without backend)
  // ============================================================

  /// Mock fetch by barcode for development.
  Future<AssetDto> _mockFetchByBarcode(String code) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Generate mock asset based on code
    final mockAssets = {
      '123456': AssetDto(
        id: 1,
        code: '123456',
        name: 'Notebook Dell Latitude',
        description: 'Notebook Dell Latitude 5520, i7, 16GB RAM, 512GB SSD',
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
        supplierId: 1,
        supplierName: 'Dell Brasil',
      ),
      '789012': AssetDto(
        id: 2,
        code: '789012',
        name: 'Monitor LG 27"',
        description: 'Monitor LG UltraWide 27" IPS',
        serialNumber: 'LG-2024-002',
        category: 'Eletronico',
        status: 'ativo',
        sectorId: 1,
        sectorName: 'TI',
        locationId: 1,
        locationName: 'Sala 101',
        acquisitionDate: '2024-02-20',
        purchaseValue: 1800.00,
        currentValue: 1620.00,
        supplierId: 2,
        supplierName: 'LG Electronics',
      ),
      '345678': AssetDto(
        id: 3,
        code: '345678',
        name: 'Cadeira Ergonômica',
        description: 'Cadeira ergonômica com apoio lombar',
        serialNumber: null,
        category: 'Movel',
        status: 'em_manutencao',
        sectorId: 2,
        sectorName: 'Administrativo',
        locationId: 3,
        locationName: 'Sala 201',
        acquisitionDate: '2023-06-10',
        purchaseValue: 1200.00,
        currentValue: 960.00,
        supplierId: 3,
        supplierName: 'Móveis Corp',
      ),
    };

    // Return mock asset if code matches, otherwise generate generic one
    if (mockAssets.containsKey(code)) {
      return mockAssets[code]!;
    }

    // For any other code, generate a generic mock asset
    return AssetDto(
      id: int.tryParse(code) ?? code.hashCode,
      code: code,
      name: 'Ativo $code',
      description: 'Descrição do ativo com código $code',
      serialNumber: 'SN-$code',
      category: 'Utilitarios',
      status: 'ativo',
      sectorId: 1,
      sectorName: 'Geral',
      locationId: 1,
      locationName: 'Almoxarifado',
      acquisitionDate: '2024-01-01',
      purchaseValue: 1000.00,
      currentValue: 900.00,
      supplierId: null,
      supplierName: null,
    );
  }
}
