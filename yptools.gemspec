
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "yptools"
  spec.version       = '1.0.11'
  spec.authors       = ["chenghengsheng"]
  spec.email         = ["2534550460@qq.com"]

  spec.summary       = %q{YPTools!}
  spec.description   = %q{Some useful tools make me happy}
  spec.homepage      = "https://github.com/HansenCCC/YPTools.git"
  spec.license       = "MIT"
  spec.files         = Dir['lib/**/*']
  spec.executables = ['yptools']
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler"
  spec.add_dependency "rake"
  spec.add_dependency "minitest"
  spec.add_dependency "colored"
  spec.add_dependency "fileutils"
  spec.add_dependency "plist"
  spec.add_dependency "xcodeproj"
  spec.add_dependency "json"
  
end
