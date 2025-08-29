# Rick and Morty Characters App

A modern iOS application built with **Clean Architecture** principles, showcasing a seamless integration of **SwiftUI** and **UIKit** to display characters from the Rick and Morty universe.

## 📱 Features

- **Character List**: Browse through Rick and Morty characters with pagination
- **Character Details**: View detailed information about each character
- **Filtering**: Filter characters by status (Alive, Dead, Unknown)
- **Image Caching**: Efficient image loading and caching
- **Pull-to-Refresh**: Refresh character data with pull gesture
- **Infinite Scrolling**: Load more characters as you scroll
- **Error Handling**: Comprehensive error handling with retry functionality
- **Offline Support**: Graceful handling of network connectivity issues

## 🏗️ Architecture

This project follows **Clean Architecture** principles, ensuring separation of concerns, testability, and maintainability.

### Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   ViewModels    │  │   ViewControllers│  │  SwiftUI    │ │
│  │                 │  │                 │  │   Views     │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Use Cases     │  │   Entities      │  │  Protocols  │ │
│  │                 │  │                 │  │             │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │  Repositories   │  │   Data Sources  │  │     DTOs    │ │
│  │                 │  │                 │  │             │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                  Infrastructure Layer                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │  Network Layer  │  │   Image Cache   │  │  Dependency │ │
│  │                 │  │                 │  │  Injection  │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Key Architectural Principles

#### 1. **Dependency Inversion**
- High-level modules don't depend on low-level modules
- Both depend on abstractions (protocols)
- Dependencies are injected, not created internally

#### 2. **Single Responsibility**
- Each class/module has one reason to change
- Clear separation of concerns across layers

#### 3. **Open/Closed Principle**
- Open for extension, closed for modification
- New features can be added without changing existing code

#### 4. **Interface Segregation**
- Clients shouldn't depend on interfaces they don't use
- Small, focused protocols

## 🎨 SwiftUI + UIKit Integration

This project demonstrates a **hybrid approach** combining the best of both SwiftUI and UIKit:

### Integration Strategy

#### 1. **UIKit as the Foundation**
```swift
// Main navigation and complex layouts
class CharactersListViewController: UITableViewController {
    // Handles complex table view operations
    // Manages navigation flow
    // Coordinates with ViewModels
}
```

#### 2. **SwiftUI for Component Views**
```swift
// Reusable, declarative components
struct CharacterRow: View {
    let character: CharacterResponse
    
    var body: some View {
        HStack {
            AsyncImage(url: character.imageUrl) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading) {
                Text(character.name)
                    .font(.headline)
                Text(character.species)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            StatusBadge(status: character.status)
        }
    }
}
```

#### 3. **UIHostingController Bridge**
```swift
// Seamless integration between UIKit and SwiftUI
let characterRow = CharacterRow(character: character)
cell.contentConfiguration = UIHostingConfiguration {
    characterRow
}
```

### Benefits of This Approach

- **Performance**: UIKit handles complex list operations efficiently
- **Flexibility**: SwiftUI provides modern, declarative UI components
- **Maintainability**: Clear separation between navigation logic and UI components
- **Reusability**: SwiftUI components can be easily reused across the app
- **Modern UI**: Leverages SwiftUI's powerful layout and animation capabilities

## 📁 Project Structure

```
Yassir Task/
├── Application/
│   └── DIContainer/
│       ├── AppDIContainer.swift          # Dependency injection container
│       └── AppFlowCoordinator.swift      # Main app flow coordination
├── Infrastructure/
│   ├── DataTransferService.swift         # Network abstraction
│   ├── Endpoint.swift                    # API endpoint definitions
│   ├── NetworkConfig.swift              # Network configuration
│   └── NetworkService.swift             # Core network service
├── Modules/
│   └── CharactersList/
│       ├── Data/
│       │   ├── CharactersRepository/
│       │   │   └── CharactersRepository.swift
│       │   └── Network/
│       │       ├── CharacterEndPoint.swift
│       │       ├── Data Model/
│       │       │   └── CharactersListResponseDTO.swift
│       │       └── Data Mapping/
│       │           └── CharactersResponseMapping.swift
│       ├── Domain/
│       │   ├── Entity/
│       │   │   ├── CharacterResponse.swift
│       │   │   ├── CharactersListResponse.swift
│       │   │   └── Info.swift
│       │   ├── Interfaces/
│       │   │   └── Repositories/
│       │   │       └── CharactersRepositoryProtocol.swift
│       │   └── UseCases/
│       │       └── CharactersUseCase.swift
│       ├── Flow/
│       │   └── CharacterListFlowCoordinator.swift
│       └── Presentation/
│           ├── View/
│           │   ├── CharacterListViewController.swift
│           │   └── Components/
│           │       ├── CharacterRow.swift
│           │       ├── CharacterDetailsView.swift
│           │       ├── FilterButtonCell.swift
│           │       └── ImageCache.swift
│           └── ViewModel/
│               └── CharactersListViewModel.swift
└── Yassir TaskTests/
    └── Modules/
        └── CharactersList/
            ├── Data/
            │   └── CharactersRepositoryTests.swift
            ├── Domain/
            │   └── CharactersUseCaseTests.swift
            ├── Presentation/
            │   └── CharactersListViewModelTests.swift
            └── Helpers/
                ├── CharactersListTestDataFactory.swift
                ├── MockCharactersUseCase.swift
                ├── MockCharactersRepository.swift
                └── MockCharacterListViewModelActions.swift
```

## 🧪 Testing Strategy

### Test Coverage
- **Unit Tests**: 65+ test methods covering all ViewModel functionality
- **Integration Tests**: End-to-end user flow testing
- **Performance Tests**: Large dataset handling validation
- **Error Handling Tests**: Comprehensive error scenario coverage

### Test Categories
- **Initialization Tests**: ViewModel setup and configuration
- **Data Loading Tests**: Success and failure scenarios
- **Filtering Tests**: All filter combinations and edge cases
- **Pagination Tests**: Multi-page navigation and boundary conditions
- **State Management Tests**: Loading states and transitions
- **Error Recovery Tests**: Network failure and retry scenarios
- **Performance Tests**: Large dataset handling (up to 10,000 items)
- **Memory Management Tests**: Leak prevention and cleanup

### Testing Principles
- **AAA Pattern**: Arrange, Act, Assert
- **Mock Objects**: Isolated testing with controlled dependencies
- **Async Testing**: Proper handling of asynchronous operations
- **Edge Cases**: Comprehensive coverage of boundary conditions

## 🚀 Getting Started

### Prerequisites
- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/rick-and-morty-app.git
   cd rick-and-morty-app
   ```

2. **Open the project**
   ```bash
   open "Yassir Task.xcodeproj"
   ```

3. **Build and run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

### Dependencies
- **No external dependencies** - Pure Swift implementation
- **Native frameworks only**: UIKit, SwiftUI, Combine, Foundation

## 🎥 Demo Video

<!-- TODO: Add demo video here -->
*Demo video will be added here showcasing the app's features and functionality.*

## 🔧 Key Technologies

### Core Technologies
- **Swift 5.7+**: Modern Swift with async/await
- **UIKit**: Navigation, table views, and complex layouts
- **SwiftUI**: Declarative UI components and modern interfaces
- **Combine**: Reactive programming and data binding
- **Foundation**: Core system frameworks

### Architecture Patterns
- **MVVM**: Model-View-ViewModel pattern
- **Coordinator Pattern**: Navigation flow management
- **Repository Pattern**: Data access abstraction
- **Dependency Injection**: Loose coupling and testability

### Design Patterns
- **Protocol-Oriented Programming**: Flexible and testable code
- **Factory Pattern**: Object creation abstraction
- **Observer Pattern**: Reactive data binding
- **Singleton Pattern**: Shared resources (ImageCache)

## 📊 Performance Optimizations

### Image Caching
- **NSCache-based**: Automatic memory management
- **Async Loading**: Non-blocking image downloads
- **Placeholder Support**: Smooth loading experience

### Memory Management
- **Weak References**: Prevent retain cycles
- **Proper Cleanup**: Cancellable subscriptions
- **Efficient Data Structures**: Optimized for large datasets

### Network Optimization
- **Request Deduplication**: Prevent duplicate API calls
- **Pagination**: Load data incrementally
- **Error Recovery**: Automatic retry mechanisms

## 🧩 Code Quality

### Clean Code Principles
- **Meaningful Names**: Self-documenting code
- **Small Functions**: Single responsibility
- **DRY Principle**: Don't repeat yourself
- **SOLID Principles**: Object-oriented design best practices

### Code Organization
- **Modular Structure**: Clear separation of concerns
- **Consistent Naming**: Swift naming conventions
- **Documentation**: Comprehensive code comments
- **Type Safety**: Leveraging Swift's type system

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Swift style guidelines
- Write comprehensive tests
- Maintain clean architecture principles
- Document public APIs
- Ensure backward compatibility

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Khaled Elshamy**
- GitHub: [@khaledelshamy](https://github.com/khaledelshamy)
- LinkedIn: [Khaled Elshamy](https://linkedin.com/in/khaledelshamy)

## 🙏 Acknowledgments

- **Rick and Morty API**: [https://rickandmortyapi.com/](https://rickandmortyapi.com/)
- **Clean Architecture**: Inspired by Uncle Bob's principles
- **iOS Community**: For best practices and patterns

---

**Built with ❤️ using Clean Architecture and modern iOS development practices**
