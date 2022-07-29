
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "yptools"
  spec.version       = '1.0.1'
  spec.authors       = ["chenghengsheng"]
  spec.email         = ["2534550460@qq.com"]

  spec.summary       = %q{YPTools!}
  spec.description   = %q{Some useful tools make me happy}
  spec.homepage      = "https://github.com/HansenCCC/YPTools.git"
  spec.license       = "MIT"
  spec.files         = Dir['lib/**/*']
  spec.executables = ['yptools']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
