## Architecture  
The project follows the MVVM architecture with Combine, separating the structure into multiple layers for better maintainability and testability.  

- **View**: The UI layer that receives user interactions and passes them to the ViewModel.  
- **ViewModel**: The core of the architecture. It navigates actions from the View, executes them via the UseCase or Coordinator, and manages data binding with the View.  
- **UseCase**: Handles business logic, including API requests and local database operations.  
- **Coordinator**: Manages app flow and navigation between scenes.  

## Technical Challenges  

### Core Data  
- **Issue**: Everything worked fine when the code was within the main app. However, after moving pieces to a submodule (`CoreDataRepository`), I encountered an issue when loading objects from persistence. By default, Core Data loads from `Current Product Module`. As I understand it, this means Core Data expects the class of the `CoreDataNote` entity to be `CoreDataRepository.CoreDataNote`, but the persistence container which stayed module expects it to be just `CoreDataNote`. It crashed as a result.
- **Solution**: I changed the entity module to `Global namespace` and loaded the `.momd` extension from the module itself using `Bundle.module`. Additionally, I used `@objc` name spacing for these entities to ensure they correctly map to the entity class name. 

### Combine  
- **Issues**:  
   1. Combine cancels the publisher pipeline after a publisher emits an error (e.g., a Core Data save context error or an API error such as a timeout or server failure). In my case, after an error was emitted, events from `ViewController` to the error pipeline in the `ViewModel` were no longer processed.  
   2. When applying multiple operators, the resulting publisher type becomes excessively long due to nesting. For example, chaining `filter`, `map`, and `first` to `AnyPublisher<Void, Never>` results in `Publishers.First<Publishers.Map<Publishers.Filter<AnyPublisher<Void, Never>>, Int>>`. At times, I encountered errors where two lengthy types did not match, or a general error stating `the compiler is unable to type-check this expression`, meaning the compiler could not pinpoint the root cause.  

- **Approach**:  
   - I changed the `Failure` type of `Publishers` in `ViewModel` to `Never` and handled errors at each step of the pipeline using [`replaceError(with:)`](https://developer.apple.com/documentation/combine/publishers/zip/replaceerror%28with:).  
   - I broke down long chains of operators into smaller publishers with only a few operators each, allowing the compiler to process them more efficiently.  

## Third-Party Libraries  
- **CombineCocoa**: Provides Combine publishers for UIKit.  
- **SnapKit**: Enables programmatic Auto Layout.  

## Demo  
- Store notes in the device’s database  
  [![WorkInLocal](https://markdown-videos-api.jorgenkh.no/url?url=https%3A%2F%2Fyoutu.be%2FeWdxryBD6CM)](https://youtu.be/eWdxryBD6CM)  

- Store notes in a remote database  
  [![HasNetworkUseCase](https://markdown-videos-api.jorgenkh.no/url?url=https%3A%2F%2Fyoutu.be%2Fs8b-v1iYQLM)](https://youtu.be/s8b-v1iYQLM)  

- Sync offline changes to the remote database  
  [![SyncOfflineChangeToRemote](https://markdown-videos-api.jorgenkh.no/url?url=https%3A%2F%2Fyoutu.be%2FTY1X3qIIOOQ)](https://youtu.be/TY1X3qIIOOQ)  
