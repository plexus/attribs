# coding: utf-8

Gem::Specification.new do |gem|
  gem.name          = "attribs"
  gem.version       = "1.0.0"
  gem.authors       = ["Arne Brasseur"]
  gem.email         = ["arne@arnebrasseur.net"]
  gem.summary       = %q{Easy and flexible Ruby value objects.}
  gem.description   = %q{Easy and flexible Ruby value objects.}
  gem.homepage      = "https://github.com/plexus/attribs"
  gem.license       = "MIT"

  gem.require_paths = ["lib"]
  gem.files         = `git ls-files -z`.split("\x0")
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.extra_rdoc_files = %w[README.md]

  gem.add_runtime_dependency "anima", "~> 0.2.0"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec", "~> 3.1"
  gem.add_development_dependency "mutant-rspec"
end
