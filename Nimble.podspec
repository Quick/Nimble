Pod::Spec.new do |s|
  s.name         = "Nimble"
  s.version      = "7.0.1"
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
    "Sources/Lib/CwlPreconditionTesting/CwlPreconditionTesting/CwlCatchBadInstructionPosix.swift",
    "Sources/Lib/CwlPreconditionTesting/CwlPreconditionTesting/Posix/CwlPreconditionTesting.h",
  ]
  s.ios.exclude_files = [
    "Sources/Lib/CwlPreconditionTesting/CwlPreconditionTesting/CwlCatchBadInstructionPOSIX.swift",
    "Sources/Lib/CwlPreconditionTesting/CwlPreconditionTesting/Posix/CwlPreconditionTesting.h",
  ]
  s.tvos.exclude_files = [
    "Sources/Lib/CwlPreconditionTesting/CwlPreconditionTesting/Mach/CwlPreconditionTesting.h",
    "Sources/Lib/CwlPreconditionTesting/CwlPreconditionTesting/CwlCatchBadInstruction.swift",
    "Sources/Lib/CwlPreconditionTesting/CwlPreconditionTesting/CwlCatchBadInstruction.m",
    "Sources/Lib/CwlPreconditionTesting/CwlPreconditionTesting/CwlBadInstructionException.swift",
    "Sources/Lib/CwlPreconditionTesting/CwlPreconditionTesting/CwlDarwinDefinitions.swift",
    "Sources/Lib/CwlPreconditionTesting/CwlCatchException/CwlCatchException.swift",
    "Sources/Lib/CwlPreconditionTesting/CwlCatchExceptionSupport/CwlCatchException.m",
    "Sources/Lib/CwlPreconditionTesting/CwlCatchExceptionSupport/include/CwlCatchException.h",
  ]

  s.private_header_files = "Sources/NimbleObjectiveC/CurrentTestCaseTracker.h"

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
