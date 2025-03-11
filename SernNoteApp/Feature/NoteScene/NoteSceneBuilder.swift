//
//  NoteSceneBuilder.swift
//  SernNoteApp
//
//  Created by sonnd on 11/3/25.
//

import UIKit
import NoteUseCase
import CoreDataRepository


struct NoteSceneBuilder {
    static func buildListScreen() -> UIViewController {
        let coordinator = NoteListCoordinatorDefault()
        let viewModel = NoteListVM(
            coreDataUseCase: CoreDataNoteUseCaseDefault(repository: CoreDataNoteRepositoryDefault.shared),
            remoteUseCase: RemoteNoteUseCase(),
            coordinator: coordinator)
        let navigationController = UINavigationController(rootViewController: NoteListVC.newVC(viewModel: viewModel))
        coordinator.navigationController = navigationController
        return navigationController
    }
}
