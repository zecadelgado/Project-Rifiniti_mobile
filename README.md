# Rifiniti Mobile

Aplicativo móvel Flutter para gestão de patrimônios, desenvolvido para integração com o sistema **Rifiniti Desk** (desktop).

## Visão Geral

O Rifiniti Mobile é um aplicativo complementar ao sistema desktop de gestão patrimonial, permitindo:

- **Scanner de Códigos**: Leitura de códigos de barras e QR codes para consulta rápida de ativos
- **Consulta de Ativos**: Visualização detalhada de patrimônios cadastrados
- **Movimentações**: Registro de transferências, empréstimos, devoluções e manutenções
- **Sincronização Offline**: Operações em modo offline com sincronização posterior

## Arquitetura

O projeto segue a **Clean Architecture** com as seguintes camadas:

```
lib/
├── app/                    # Configuração do app (router, tema)
├── core/                   # Utilitários compartilhados
│   ├── config/             # Configurações (env, endpoints)
│   ├── constants/          # Constantes e strings
│   ├── errors/             # Tratamento de erros
│   ├── network/            # Cliente HTTP (Dio)
│   ├── storage/            # Armazenamento local (Hive, SecureStorage)
│   ├── theme/              # Tema do app
│   └── utils/              # Utilitários (formatters, validators)
└── features/               # Features do app
    ├── auth/               # Autenticação
    ├── scanner/            # Scanner de códigos
    ├── assets/             # Gestão de ativos
    ├── movements/          # Movimentações
    └── settings/           # Configurações
```

Cada feature segue a estrutura:

```
feature/
├── data/
│   ├── datasources/        # Fontes de dados (remote, local)
│   ├── models/             # DTOs
│   └── repositories/       # Implementação dos repositórios
├── domain/
│   ├── entities/           # Entidades de domínio
│   ├── repositories/       # Interfaces dos repositórios
│   └── usecases/           # Casos de uso
└── presentation/
    ├── controllers/        # State management (Riverpod)
    ├── pages/              # Telas
    └── widgets/            # Widgets específicos
```

## Tecnologias

- **Flutter 3.x** - Framework UI
- **Riverpod** - Gerenciamento de estado
- **GoRouter** - Navegação
- **Dio** - Cliente HTTP
- **Hive** - Banco de dados local
- **Flutter Secure Storage** - Armazenamento seguro
- **Mobile Scanner** - Leitura de códigos

## Configuração

### Pré-requisitos

- Flutter SDK 3.x
- Dart SDK 3.x
- Android Studio / Xcode

### Instalação

1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/rifiniti_mobile.git
cd rifiniti_mobile
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Configure o arquivo `.env`:
```bash
cp .env.example .env
# Edite o arquivo .env com as configurações do servidor
```

4. Execute o app:
```bash
flutter run
```

### Variáveis de Ambiente

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `API_BASE_URL` | URL base da API do Rifiniti Desk | `http://192.168.1.100:8080/api` |
| `API_TIMEOUT` | Timeout das requisições (ms) | `30000` |
| `ENV` | Ambiente (dev/staging/prod) | `dev` |

## Integração com Rifiniti Desk

O aplicativo se comunica com o servidor desktop através de uma API REST. Para configurar:

1. Certifique-se de que o Rifiniti Desk está rodando com a API habilitada
2. Configure o endereço do servidor nas configurações do app ou no `.env`
3. Faça login com as credenciais do sistema desktop

### Endpoints da API

| Endpoint | Método | Descrição |
|----------|--------|-----------|
| `/auth/login` | POST | Autenticação |
| `/auth/logout` | POST | Logout |
| `/assets` | GET | Listar ativos |
| `/assets/{id}` | GET | Detalhes do ativo |
| `/assets/barcode/{code}` | GET | Buscar por código |
| `/movements` | GET | Listar movimentações |
| `/movements` | POST | Criar movimentação |

## Funcionalidades

### Scanner

- Leitura de códigos de barras (EAN-13, Code 128, etc.)
- Leitura de QR codes
- Flash e troca de câmera
- Consulta automática do ativo após leitura

### Ativos

- Listagem com filtros (categoria, status, setor)
- Busca por nome ou código
- Visualização detalhada
- Cache offline

### Movimentações

- Registro de transferências entre setores
- Empréstimos e devoluções
- Envio para manutenção
- Histórico de movimentações

### Modo Offline

- Cache de ativos consultados
- Fila de operações pendentes
- Sincronização automática ao reconectar

## Desenvolvimento

### Estrutura de Branches

- `main` - Produção
- `develop` - Desenvolvimento
- `feature/*` - Novas funcionalidades
- `bugfix/*` - Correções

### Comandos Úteis

```bash
# Gerar código (build_runner)
flutter pub run build_runner build --delete-conflicting-outputs

# Executar testes
flutter test

# Análise de código
flutter analyze

# Build Android
flutter build apk --release

# Build iOS
flutter build ios --release
```

## Licença

Este projeto é proprietário e desenvolvido para uso interno.

## Contato

Para suporte ou dúvidas, entre em contato com a equipe de desenvolvimento.
