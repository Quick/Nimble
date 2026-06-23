import ProjectDescription

let bundleIDPrefix = "net.jeffhui"
let destinations: Destinations = .iOS.union(Destinations.macOS)
let deploymentTargets: DeploymentTargets =  .multiplatform(iOS: "15.0", macOS: "12.0")

let target: Target = .target(
  name: "Nimble",
  destinations: destinations,
  product: .framework,
  bundleId: "\(bundleIDPrefix).Nimble",
  deploymentTargets: deploymentTargets,
  infoPlist: "Sources/Nimble/Info.plist",
  sources: [
    .glob(
      "Sources/Nimble/**",
      excluding: ["Sources/Nimble/Adapters/NonObjectiveC/ExceptionCapture.swift"]
    ),
    "Sources/NimbleObjectiveC/**",
  ],
  headers: .headers(
      public: [
          "Sources/NimbleObjectiveC/include/**",
          "Sources/Nimble/Nimble.h"
      ]
  ),
  dependencies: [
    .package(product: "CwlCatchException"),
    .package(product: "CwlPreconditionTesting"),
    .package(product: "CwlPosixPreconditionTesting"),
  ],
  settings: .settings(
      base: [
          "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
          "DEFINES_MODULE": "YES",
          "DYLIB_COMPATIBILITY_VERSION": "1",
          "DYLIB_CURRENT_VERSION": "1",
          "DYLIB_INSTALL_NAME_BASE": "@rpath",
          "GCC_PREPROCESSOR_DEFINITIONS": "$(inherited)",
          "GCC_TREAT_WARNINGS_AS_ERRORS": "YES",
          "INSTALL_PATH": "$(LOCAL_LIBRARY_DIR)/Frameworks",
          "LD_RUNPATH_SEARCH_PATHS":
            "$(inherited) @executable_path/Frameworks @loader_path/Frameworks",
          "SKIP_INSTALL": "YES",
          "SUPPORTS_MACCATALYST": "YES",
      ],
      configurations: [
          .debug(name: "Debug"),
          .release(name: "Release")
      ],
      defaultSettings: .none
  )
)

let testTarget: Target = .target(
      name: "NimbleTests",
      destinations: destinations,
      product: .unitTests,
      bundleId: "\(bundleIDPrefix).NimbleTests",
      deploymentTargets: deploymentTargets,
      infoPlist: "Tests/NimbleTests/Info.plist",
      sources: [
        "Tests/**",
        "Sources/NimbleSharedTestHelpers/**"
      ],
      headers: .headers(project: "Tests/NimbleObjectiveCTests/**"),
      dependencies: [
          .target(name: "Nimble")
      ],
      settings: .settings(
          base: [
              "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
              "CLANG_ENABLE_MODULES": "YES",
              "SUPPORTS_MACCATALYST": "YES",
              "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
              "COMBINE_HIDPI_IMAGES": "YES",
              "LD_RUNPATH_SEARCH_PATHS":
                "$(inherited) @executable_path/Frameworks @loader_path/Frameworks",

              "GCC_PREPROCESSOR_DEFINITIONS": "DEBUG=1 $(inherited)",
              "METAL_ENABLE_DEBUG_INFO": "YES",
              "SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD": "YES",
          ],
          configurations: [
              .debug(name: "Debug"),
              .release(name: "Release")
          ],
          defaultSettings: .none
      )
  )

let project = Project(
    name: "Nimble",
    organizationName: bundleIDPrefix,
    packages: [
      .package(url: "https://github.com/mattgallagher/CwlCatchException", from: "2.1.2"),
      .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting", from: "2.2.0"),
    ],
    settings: .settings(
      configurations: [
          .debug(name: "Debug", xcconfig: "Configurations/Debug.xcconfig"),
          .release(name: "Release", xcconfig: "Configurations/Release.xcconfig")
      ],
      defaultSettings: .none
    ),
    targets: [
        target,
        testTarget
    ],
    schemes: [
      .scheme(
        name: "Nimble",
        buildAction: .buildAction(targets: ["Nimble"]),
        testAction: .targets(
          [.testableTarget(target: "NimbleTests", isParallelizable: true)],
          attachDebugger: false
        )
      )
    ]
)
