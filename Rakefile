require 'rubygems/package_task'

spec = Gem::Specification.load(File.expand_path('../attribs.gemspec', __FILE__))
gem = Gem::PackageTask.new(spec)
gem.define

desc "Push gem to rubygems.org"
task :push => :gem do
  sh "git tag v#{spec.version}"
  sh "git push --tags"
  sh "gem push pkg/attribs-#{spec.version}.gem"
end

require 'mutant'
task :default => :mutant

desc "run mutant"
task :mutant do
  pattern = ENV.fetch('PATTERN', 'Attribs*')
  opts    = ENV.fetch('MUTANT_OPTS', '').split(' ')
  result  = Mutant::CLI.run(%w[-Ilib -rattribs --use rspec --score 100] + opts + [pattern])
  fail unless result == Mutant::CLI::EXIT_SUCCESS
end

require 'rspec/core/rake_task'

desc "run rspec"
RSpec::Core::RakeTask.new(:rspec) do |t, task_args|
  t.rspec_opts = "-Ispec"
  t.pattern = "spec"
end
