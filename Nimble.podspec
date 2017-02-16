Pod::Spec.new do |s|
  s.name         = "Nimble"
  s.version      = "6.0.1"
  s.summary      = "A Matcher Framework for Swift and Objective-C"
  s.description  = <<-DESC
                   Use Nimble to express the expected outcomes of Swift or Objective-C expressions. Inspired by Cedar.
                   DESC
  s.homepage     = "https://github.com/Quick/Nimble"
  s.license      = { :type => "Apache 2.0", :file => "LICENSE" }
  s.author       = "Quick Contributors"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/Quick/Nimble.git",
                     :tag => "v#{s.version}" }

  s.source_files = "Sources/**/*.{swift,h,m,c}"

  s.osx.exclude_files = [
    "Sources/Lib/CwlPreconditionTesting/CwlPreconditionTesting/CwlCatchBadInstructionPOSIX.swift",
  ]
  s.ios.exclude_files = [
    "Sources/Lib/CwlPreconditionTesting/CwlPreconditionTesting/CwlCatchBadInstructionPOSIX.swift",
  ]
  s.tvos.exclude_files = [
    "Sources/Lib/CwlPreconditionTesting/CwlPreconditionTesting/CwlCatchBadInstruction.swift",
    "Sources/Lib/CwlPreconditionTesting/CwlPreconditionTesting/CwlCatchBadInstruction.m",
    "Sources/Lib/CwlPreconditionTesting/CwlPreconditionTesting/CwlBadInstructionException.swift",
    "Sources/Lib/CwlPreconditionTesting/CwlPreconditionTesting/CwlDarwinDefinitions.swift",
    "Sources/Lib/CwlPreconditionTesting/CwlPreconditionTesting/mach_excServer.{h,c}",
    "Sources/Lib/CwlPreconditionTesting/CwlCatchException/CwlCatchException.swift",
    "Sources/Lib/CwlPreconditionTesting/CwlCatchException/CwlCatchException.m",
  ]

  s.private_header_files = "Sources/NimbleObjectiveC/CurrentTestCaseTracker.h"
  s.tvos.private_header_files = "Sources/Lib/CwlPreconditionTesting/CwlPreconditionTesting/mach_excServer.h"

  s.exclude_files = "Sources/Nimble/Adapters/NonObjectiveC/*.swift"
  s.weak_framework = "XCTest"
  s.requires_arc = true
  s.compiler_flags = '-DPRODUCT_NAME=Nimble/Nimble'
  s.pod_target_xcconfig = {
    'ENABLE_BITCODE' => 'NO',
    'OTHER_LDFLAGS' => '-weak-lswiftXCTest',
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "$(PLATFORM_DIR)/Developer/Library/Frameworks"',
  }
end
