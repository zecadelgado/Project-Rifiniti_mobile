/// Application strings in Portuguese (Brazil).
/// All user-facing text should be defined here for easy localization.
abstract class AppStrings {
  // ============================================================
  // APP GENERAL
  // ============================================================
  static const appName = 'Rifiniti Mobile';
  static const appDescription = 'Gestão Patrimonial Mobile';

  // ============================================================
  // COMMON
  // ============================================================
  static const loading = 'Carregando...';
  static const error = 'Erro';
  static const success = 'Sucesso';
  static const cancel = 'Cancelar';
  static const confirm = 'Confirmar';
  static const save = 'Salvar';
  static const delete = 'Excluir';
  static const edit = 'Editar';
  static const search = 'Buscar';
  static const filter = 'Filtrar';
  static const clear = 'Limpar';
  static const retry = 'Tentar novamente';
  static const back = 'Voltar';
  static const next = 'Próximo';
  static const close = 'Fechar';
  static const yes = 'Sim';
  static const no = 'Não';
  static const noData = 'Nenhum dado encontrado';
  static const offline = 'Você está offline';
  static const online = 'Conectado';

  // ============================================================
  // AUTH
  // ============================================================
  static const login = 'Entrar';
  static const logout = 'Sair';
  static const email = 'E-mail';
  static const password = 'Senha';
  static const emailHint = 'Digite seu e-mail';
  static const passwordHint = 'Digite sua senha';
  static const loginTitle = 'Bem-vindo ao Rifiniti';
  static const loginSubtitle = 'Faça login para continuar';
  static const loginSuccess = 'Login realizado com sucesso!';
  static const loginError = 'E-mail ou senha incorretos';
  static const logoutConfirm = 'Deseja realmente sair?';
  static const sessionExpired = 'Sua sessão expirou. Faça login novamente.';
  static const invalidEmail = 'E-mail inválido';
  static const invalidPassword = 'Senha deve ter pelo menos 6 caracteres';
  static const requiredField = 'Campo obrigatório';

  // ============================================================
  // SCANNER
  // ============================================================
  static const scannerTitle = 'Scanner';
  static const scannerSubtitle = 'Aponte a câmera para o código de barras ou QR Code';
  static const scannerPermissionDenied = 'Permissão de câmera negada';
  static const scannerPermissionRequest = 'Precisamos de acesso à câmera para escanear códigos';
  static const scannerNoCode = 'Nenhum código detectado';
  static const scannerSearching = 'Buscando ativo...';
  static const scannerNotFound = 'Ativo não encontrado para este código';
  static const scannerSuccess = 'Código escaneado com sucesso!';
  static const enableFlash = 'Ativar flash';
  static const disableFlash = 'Desativar flash';
  static const switchCamera = 'Alternar câmera';

  // ============================================================
  // SCAN RESULT
  // ============================================================
  static const scanResultTitle = 'Resultado da Leitura';
  static const scannedCode = 'Código lido';
  static const registerMovement = 'Registrar Movimentação';
  static const openDetails = 'Abrir Detalhes';
  static const scanAgain = 'Escanear Novamente';

  // ============================================================
  // ASSETS
  // ============================================================
  static const assetsTitle = 'Ativos';
  static const assetDetailsTitle = 'Detalhes do Ativo';
  static const assetId = 'ID';
  static const assetName = 'Nome';
  static const assetDescription = 'Descrição';
  static const assetCode = 'Número Patrimonial';
  static const assetSerialNumber = 'Número de Série';
  static const assetCategory = 'Categoria';
  static const assetStatus = 'Status';
  static const assetSector = 'Setor';
  static const assetLocation = 'Local';
  static const assetAcquisitionDate = 'Data de Aquisição';
  static const assetPurchaseValue = 'Valor de Compra';
  static const assetCurrentValue = 'Valor Atual';
  static const assetSupplier = 'Fornecedor';
  static const assetInvoice = 'Nota Fiscal';
  static const assetQuantity = 'Quantidade';
  static const searchAssets = 'Buscar ativos...';

  // Asset Status
  static const statusActive = 'Ativo';
  static const statusInactive = 'Baixado';
  static const statusMaintenance = 'Em Manutenção';
  static const statusMissing = 'Desaparecido';

  // ============================================================
  // MOVEMENTS
  // ============================================================
  static const movementsTitle = 'Movimentações';
  static const createMovementTitle = 'Nova Movimentação';
  static const movementType = 'Tipo de Movimentação';
  static const movementDate = 'Data';
  static const movementOrigin = 'Origem';
  static const movementDestination = 'Destino';
  static const movementResponsible = 'Responsável';
  static const movementReason = 'Motivo';
  static const movementNotes = 'Observações';
  static const destinationSector = 'Setor de Destino';
  static const destinationLocation = 'Local de Destino';
  static const responsible = 'Responsável';
  static const reason = 'Motivo';
  static const notes = 'Observações';
  static const movementCreated = 'Movimentação registrada com sucesso!';
  static const movementError = 'Erro ao registrar movimentação';
  static const noMovements = 'Nenhuma movimentação registrada';
  static const recentMovements = 'Movimentações Recentes';
  static const pendingSync = 'Pendente de sincronização';

  // Movement Types
  static const typeTransfer = 'Transferência';
  static const typeLoan = 'Empréstimo';
  static const typeReturn = 'Devolução';
  static const typeMaintenance = 'Manutenção';

  // ============================================================
  // SETTINGS
  // ============================================================
  static const settingsTitle = 'Configurações';
  static const settingsAccount = 'Conta';
  static const settingsSync = 'Sincronização';
  static const settingsAbout = 'Sobre';
  static const settingsVersion = 'Versão';
  static const settingsServerUrl = 'URL do Servidor';
  static const settingsLastSync = 'Última sincronização';
  static const settingsSyncNow = 'Sincronizar agora';
  static const settingsSyncPending = 'operações pendentes';
  static const settingsClearCache = 'Limpar cache';
  static const settingsCacheCleared = 'Cache limpo com sucesso';
  static const settingsTheme = 'Tema';
  static const settingsThemeLight = 'Claro';
  static const settingsThemeDark = 'Escuro';
  static const settingsThemeSystem = 'Sistema';

  // ============================================================
  // ERRORS
  // ============================================================
  static const errorGeneric = 'Ocorreu um erro. Tente novamente.';
  static const errorNetwork = 'Erro de conexão. Verifique sua internet.';
  static const errorServer = 'Erro no servidor. Tente mais tarde.';
  static const errorTimeout = 'Tempo de conexão esgotado.';
  static const errorUnauthorized = 'Não autorizado. Faça login novamente.';
  static const errorNotFound = 'Recurso não encontrado.';
  static const errorValidation = 'Dados inválidos. Verifique os campos.';
  static const errorOfflineAction = 'Esta ação será sincronizada quando houver conexão.';
}
