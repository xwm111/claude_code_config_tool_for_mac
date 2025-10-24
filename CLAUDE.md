# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ClaudeCodeConfig is a native macOS application for managing Claude Code CLI configurations offline. It provides a graphical interface to create, validate, and launch Claude Code development environments with iTerm2 integration.

**Technology Stack:**
- Swift 6.0+ / SwiftUI
- Core Data (persistence layer)
- Keychain (secure credential storage)
- Python 3.11+ (MCP server)
- Xcode 16.0+

## Build and Development Commands

### Building the Application
```bash
# Open project in Xcode
open ClaudeCodeConfig.xcodeproj

# Build from command line (note: project file may have issues, prefer Xcode GUI)
xcodebuild -project ClaudeCodeConfig.xcodeproj -scheme ClaudeCodeConfig -configuration Debug build

# Build demo executables
swiftc demos/cccfg.swift -o demos/cccfg
```

### Running Tests
```bash
# Run all tests
xcodebuild test -project ClaudeCodeConfig.xcodeproj -scheme ClaudeCodeConfig

# Run specific test target
xcodebuild test -project ClaudeCodeConfig.xcodeproj -scheme ClaudeCodeConfig -only-testing:UnitTests
xcodebuild test -project ClaudeCodeConfig.xcodeproj -scheme ClaudeCodeConfig -only-testing:IntegrationTests
```

### MCP DateTime Server
```bash
# Run the MCP datetime server (used for time-related operations)
python3 mcp_datetime_server.py
```

## Architecture

### Core Components

**1. Data Layer (Core Data)**
- `CoreDataManager`: Singleton managing NSPersistentContainer, provides main and background contexts
- `ConfigurationMO`: Main entity for storing configuration data (name, URL, working directory, validation state)
- `ValidationErrorMO`: Stores validation errors linked to configurations
- `SystemResourceMO`: Manages help docs and other system resources
- Database Location: `~/Library/Application Support/ClaudeCodeConfig/ClaudeCodeConfig.sqlite`

**2. Repository Pattern**
- `RepositoryProtocol`: Base protocol for data access operations
- `ConfigurationRepository`: CRUD operations for configurations with default config management
- Provides abstraction over Core Data operations

**3. Services Layer**
- `ValidationService`: Configuration and data validation logic
- `LaunchService`: Orchestrates iTerm2 launches with configuration
- `DependencyValidator`: Checks system dependencies (iTerm2, Claude Code CLI)
- `LocalValidator`: Offline validation without network calls
- `ErrorHandlingService`: Centralized error handling and user-friendly messages
- `ResourceManager`: Manages help documentation and templates
- `ContextualHelpService`: Provides context-sensitive help

**4. Security**
- `KeychainManager`: Secure storage/retrieval of API keys and sensitive data
  - Service identifier: `com.claudecode.config`
  - Supports multiple key types: apiKey, accessToken, refreshToken, certificate, privateKey
  - All sensitive data MUST use Keychain, never stored in Core Data

**5. Views (SwiftUI)**
- `MainContentView`: Tab-based root view (Configuration, Environment Check, Quick Launch, Help)
- `ConfigurationView`: List and manage configurations
- `EnvironmentCheckView`: System dependency validation UI
- `LaunchConfigurationView`: Quick launch interface
- `HelpView`: Integrated help system with search
- `ErrorDisplayView`: Error presentation with suggested actions

**6. ViewModels**
- `LaunchConfigurationViewModel`: Launch workflow state management
- `EnvironmentValidationViewModel`: Dependency check results
- `ErrorResolutionViewModel`: Error resolution suggestions

**7. Offline Mode**
- `OfflineModeManager`: Manages offline capability
- All operations work without network access
- Local validation replaces API calls when offline

### Data Flow

```
User Interaction (View)
    ↓
ViewModel (state management)
    ↓
Service Layer (business logic)
    ↓
Repository (data access)
    ↓
Core Data Manager
    ↓
SQLite Database / Keychain
```

### Key Architectural Patterns

- **MVVM**: Views bind to ViewModels for reactive UI updates
- **Repository Pattern**: Abstracted data access layer
- **Dependency Injection**: Services accept dependencies in initializers for testability
- **Singleton Pattern**: CoreDataManager, KeychainManager, OfflineModeManager
- **Protocol-Oriented**: Extensive use of protocols for extensibility (ModelProvider, ConfigPlugin, ValidationRule)

## Important Development Conventions

### System Time Retrieval
**CRITICAL**: Always use the MCP datetime server for time operations, NOT system datetime functions.

```python
# ✅ CORRECT - Use MCP tool
result = mcp_call_tool("get_current_time")
current_time = json.loads(result["content"][0]["text"])

# ❌ WRONG - Do not use directly
import datetime
now = datetime.datetime.now()  # Never do this
```

### Keychain Security
- API keys and sensitive data MUST be stored in Keychain via `KeychainManager`
- Never log or print sensitive information
- Core Data stores only configuration metadata, not secrets

### iTerm2 Integration
- Uses AppleScript for iTerm2 automation
- Launch workflow: validate config → check iTerm2 → prepare environment → execute AppleScript
- Working directory and API keys injected into terminal session

### Core Data Best Practices
- Always use `viewContext` for UI operations (main thread)
- Use `backgroundContext` for background operations
- CoreDataManager automatically saves on app resign/terminate
- Validation state changes trigger automatic timestamp updates

## File Structure

```
ClaudeCodeConfig/
├── ClaudeCodeConfig/          # App bundle resources
│   ├── AppDelegate.swift      # App lifecycle, Core Data initialization
│   ├── Assets.xcassets        # Images and colors
│   └── Info.plist
├── src/                       # Source code
│   ├── Models/               # Data models and ViewModels
│   │   ├── Configuration.swift         # Main config entity
│   │   ├── ValidationError.swift       # Error entity
│   │   ├── SystemResource.swift        # Help docs entity
│   │   └── OfflineModeManager.swift
│   ├── Views/                # SwiftUI views
│   │   ├── MainContentView.swift       # Root tab view
│   │   ├── ConfigurationView.swift
│   │   ├── EnvironmentCheckView.swift
│   │   ├── LaunchConfigurationView.swift
│   │   ├── HelpView.swift
│   │   └── ErrorDisplayView.swift
│   ├── Services/             # Business logic
│   │   ├── CoreDataManager.swift
│   │   ├── ConfigurationRepository.swift
│   │   ├── ValidationService.swift
│   │   ├── LaunchService.swift
│   │   ├── DependencyValidator.swift
│   │   └── ErrorHandlingService.swift
│   ├── Utilities/            # Helper code
│   │   ├── Constants.swift   # App constants, strings, colors
│   │   ├── KeychainManager.swift
│   │   └── JSONExporter.swift
│   └── Resources/            # App resources
│       ├── DataModel.xcdatamodeld  # Core Data model
│       └── HelpDocs/         # Help documentation
Tests/
├── Unit/                     # Unit tests
│   ├── Models/
│   ├── Services/
│   └── Utilities/
├── Integration/              # Integration tests
│   ├── ITerm2IntegrationTests/
│   └── OfflineModeTests/
└── UI/                       # UI tests
    ├── ConfigurationUITests/
    └── EnvironmentValidationUITests/
demos/                        # Demo/prototype Swift files
docs/                         # Documentation
└── development-guidelines.md # Development best practices
mcp_datetime_server.py        # MCP server for datetime operations
```

## Testing Strategy

- **Unit Tests**: Models, Services, Utilities (target 80%+ coverage)
- **Integration Tests**: iTerm2 integration, offline mode functionality
- **UI Tests**: Key user workflows using XCUITest
- Test discovery: Use descriptive test names with "test" prefix
- Mock external dependencies (iTerm2, Keychain) for unit tests

## Configuration Constants

Key constants defined in `src/Utilities/Constants.swift`:
- Window size: 800x600 (min), 1200x800 (default)
- Network timeout: 30s
- Validation timeout: 10s
- Max config name length: 100 chars
- Auto-save interval: 60s

## Common Tasks

### Adding a New Configuration Field
1. Update `Configuration.swift` Core Data model properties
2. Update Core Data schema in `DataModel.xcdatamodeld`
3. Add validation logic in `Configuration.validateData()`
4. Update UI in `ConfigurationEditView`
5. Update export/import in `JSONExporter`
6. Add migration if needed in `CoreDataManager`

### Adding a New Service
1. Create service class following dependency injection pattern
2. Accept dependencies in initializer for testability
3. Use protocols for external dependencies
4. Add error handling using `ErrorHandlingService`
5. Create corresponding unit tests
6. Document public methods

### Adding New Help Documentation
1. Add markdown files to `src/Resources/HelpDocs/`
2. Create `SystemResourceMO` entries in Core Data
3. Update `ResourceManager` to load new docs
4. Add search keywords for discoverability
