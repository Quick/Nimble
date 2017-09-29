Pod::Spec.new do |s|
  s.name          = "CwlPreconditionTesting"
  s.version       = "1.1.0"
  
  s.summary       = "A small Swift framework for catching Mach BAD_INSTRUCTION exceptions."
  s.description   = <<-DESC
    A Swift framework for catching Mach bad instruction exceptions as raised by Swift precondition failures, enabling testing of precondition and assertion logic. For details, see the article on [Cocoa with Love](https://cocoawithlove.com), [Partial functions in Swift, Part 2: Catching precondition failures](http://cocoawithlove.com/blog/2016/02/02/partial-functions-part-two-catching-precondition-failures.html)
  DESC
  s.homepage      = "https://github.com/mattgallagher/CwlPreconditionTesting"
  s.license       = { :type => "ISC", :file => "LICENSE.txt" }
  s.author        = "Matt Gallagher"
  
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  
  s.dependency 'CwlCatchException'
  
  s.source        = { :git => "https://github.com/mattgallagher/CwlPreconditionTesting.git", :tag => "#{s.version}" }
  s.source_files  =
    "Sources/CwlPreconditionTesting/CwlBadInstructionException.swift",
    "Sources/CwlPreconditionTesting/CwlCatchBadInstruction.swift",
    "Sources/CwlPreconditionTesting/CwlDarwinDefinitions.swift",
    "Sources/CwlPreconditionTesting/Mach/*.h",
    "Sources/CwlMachBadInstructionHandler/CwlMachBadInstructionHandler.m",
    "Sources/CwlMachBadInstructionHandler/include/CwlMachBadInstructionHandler.h"
  s.ios.source_files = "Sources/CwlMachBadInstructionHandler/mach_excServer.{c,h}"
end
