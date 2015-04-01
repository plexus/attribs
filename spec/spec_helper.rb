require 'attribs'

RSpec.configure do |rspec|
  rspec.disable_monkey_patching!
  rspec.raise_errors_for_deprecations!
  rspec.around(:each) do |example|
    Timeout.timeout(1, &example)
  end
end
