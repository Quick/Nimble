Pod::Spec.new do |s|
  s.name          = "CwlCatchException"
  s.version       = "1.0.2"
  
  s.summary       = "A small Swift framework for catching Objective-C exceptions."
  s.description   = <<-DESC
    A simple Swift wrapper around an Objective-C @try/@catch statement that selectively catches Objective-C exceptions by NSException subtype, rethrowing if any caught exception is not the expected subtype.
  DESC
  s.homepage      = "https://github.com/mattgallagher/CwlCatchException"
  s.license       = { :type => "ISC", :file => "LICENSE.txt" }
  s.author        = "Matt Gallagher"
  
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  
  s.source        = { :git => "https://github.com/mattgallagher/CwlCatchException.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/**/*.{swift,m,h}"
end
