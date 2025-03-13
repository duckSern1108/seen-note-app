//
//  NoteSceneBuilder.swift
//  SernNoteApp
//
//  Created by sonnd on 11/3/25.
//

import UIKit
import BaseNetwork
import NoteUseCase
import CoreDataRepository
import NoteRepository

struct NoteSceneBuilder {
    static func buildListScreen() -> UIViewController {
        let coordinator = NoteListCoordinatorDefault()
        let remoteRepository = NoteRepositoryDefault(client: NetworkClient(session: URLSession.shared))
        let viewModel = NoteListVM(
            coreDataUseCase: CoreDataNoteUseCaseDefault(repository: CoreDataNoteRepositoryDefault.shared),
            remoteUseCase: RemoteNoteUseCase(repository: remoteRepository),
            coordinator: coordinator)
        let navigationController = UINavigationController(rootViewController: NoteListVC.newVC(viewModel: viewModel))
        coordinator.navigationController = navigationController
        return navigationController
    }
}
