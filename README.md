
## Architecture
MVVM & Combine, separate structure into several layers which is easy to maintain and do test

- **View**: UI part, receive user's interaction and pass it to ViewModel
- **ViewModel**: Center of the entire architecture, navigate actions from View then execute on UseCase / Navigator, also has data binding mechanism with View
- **UseCase**: Execute business logic, requesting API or local database
- **Coordinator**: Handle app flow and navigate between scenes

## Technical challenging
### CoreData
- **Issue**: Everything worked fine when code stay in main app, then after moved peices to sub-module, I encoutered issue when loading the object from persistence. By default, it will load from `Current Product Module` ( As I understand, using this value, Core Data expect class of `CoreDataNote` entity is `CoreDataRepository.CoreDataNote`, but persistence which stay in module expect class to be just `CoreDataNote`).  It crashed as a result. 
- **Solution**: I've changed entity module to `Global namespace` then loaded `momd extension` from module itself using `Bundle.module`. I also added name spacing @objc for these entities, to map correctly with entity class name.

### Combine
- **Issue**:
   + Combine cancel publisers pipeline after a publiser emit error ( ex: Core Data save context error, or API error like timeout, server error,... ). For my case, after an error emitted, events from `ViewController` to error pipeline in `ViewModel` will not proccess anymore.
   + When apply multiple operators,  type of result publisher become very long because It's always nested to another when you apply any operators ( Ex: chaining `filter`, `map`, `first` to ` AnyPublisher<Void, Never>` will make a `Publishers.First<Publishers.Map<Publishers.Filter<AnyPublisher<Void, Never>>, Int>>`), sometimes I have encounterd an error with 2 very long type not match each other or a general error `the compiler is unable to type-check this expression` which means compiler can not point out the root cause.
- **Approach**: 
	- I've change `Failure`'s type of `Publishers` in `ViewModel` to `Never`, I also catch errors in any steps of pipeline using [replaceError(with:)](https://developer.apple.com/documentation/combine/publishers/zip/replaceerror%28with:)
	- I've break long chaining operators into smaller publishers with just few operator so compiler can work properly.

## Third parties
- **CombineCocoa**: Combine publisher bridges for UIKit
- **SnapKit**: Autolayout programmatically
