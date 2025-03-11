// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Packages",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Domain",
            targets: ["Domain"]),
        .library(
            name: "NoteUseCase",
            targets: ["NoteUseCase"]),
        .library(
            name: "CoreDataRepository",
            targets: ["CoreDataRepository"])
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "Domain"),
        .target(
            name: "APIRouter",
            dependencies: [
                .target(name: "Domain")
            ]),
        .target(
            name: "CoreDataRepository",
            dependencies: [
                .target(name: "Domain"),
            ],
            resources: [
                .process("Resources")
            ]),
        .target(
            name: "NoteUseCase",
            dependencies: [
                .target(name: "Domain"),
                .target(name: "CoreDataRepository"),
                .target(name: "APIRouter")
            ]),
    ]
)
