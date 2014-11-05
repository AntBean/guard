# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
#

require "coveralls"
Coveralls.wear!

require "guard"
require "rspec"

path = "#{File.expand_path("..", __FILE__)}/support/**/*.rb"
Dir[path].each { |f| require f }

# TODO: these shouldn't be necessary with proper specs

def stub_guardfile(contents = nil, &block)
  stub_file(File.expand_path("Guardfile"), contents, &block)
end

def stub_user_guardfile(contents = nil, &block)
  stub_file(File.expand_path("~/.Guardfile"), contents, &block)
end

def stub_user_guard_rb(contents = nil, &block)
  stub_file(File.expand_path("~/.guard.rb"), contents, &block)
end

def stub_user_project_guardfile(contents = nil, &block)
  stub_file(File.expand_path(".Guardfile"), contents, &block)
end

# TODO: I can't wait to replace these with IO.read + rescuing Errno:ENOENT
def stub_file(path, contents = nil, &block)
  exists = !contents.nil?
  allow(File).to receive(:exist?).with(path).and_return(exists)
  return unless exists
  if block.nil?
    allow(File).to receive(:read).with(path).and_return(contents)
  else
    allow(File).to receive(:read).with(path) do
      block.call
    end
  end
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    # be_bigger_than(2).and_smaller_than(4).description
    #   # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #   # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # The settings below are suggested to provide a good initial experience
  # with RSpec, but feel free to customize to your heart's content.

  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  # config.filter_run :focus
  config.filter_run focus: ENV["CI"] != "true"

  config.run_all_when_everything_filtered = true

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended.
  #
  # For more details, see:
  #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  config.disable_monkey_patching!

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  # config.warnings = true

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    #
    # This is set in .rspec file
    # config.default_formatter = "doc"
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  # config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed

  config.raise_errors_for_deprecations!

  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
    mocks.verify_partial_doubles = true
  end

  config.before(:each) do |example|
    stub_const("FileUtils", class_double(FileUtils))

    %w(read write exist?).each do |meth|
      allow(File).to receive(meth.to_sym).with(anything) do |*args, &_block|
        abort "stub me! (File.#{meth}(#{args.inspect}))"
      end
    end

    Guard.send(:_reset_for_tests)

    Guard.clear_options

    # Stub all UI methods, so no visible output appears for the UI class
    allow(::Guard::UI).to receive(:info)
    allow(::Guard::UI).to receive(:warning)
    allow(::Guard::UI).to receive(:error)
    allow(::Guard::UI).to receive(:debug)
    allow(::Guard::UI).to receive(:deprecation)

    # Avoid clobbering the terminal
    allow(Guard::Notifier::TerminalTitle).to receive(:puts)

    allow(Guard::Notifier::Tmux).to receive(:system) do |*args|
      fail "stub for system() called with: #{args.inspect}"
    end

    allow(Guard::Notifier::Tmux).to receive(:`) do |*args|
      fail "stub for `(backtick) called with: #{args.inspect}"
    end

    allow(Kernel).to receive(:system) do |*args|
      fail "stub for Kernel.system() called with: #{args.inspect}"
    end

    unless example.metadata[:sheller_specs]
      allow(Guard::Sheller).to receive(:run) do |*args|
        fail "stub for Sheller.run() called with: #{args.inspect}"
      end
    end

    allow(Listen).to receive(:to) do |*args|
      fail "stub for Listen.to called with: #{args.inspect}"
    end

    ::Guard.reset_groups
    ::Guard.reset_plugins
  end

  config.before(:all) do
    @guard_notify ||= ENV["GUARD_NOTIFY"]
    @guard_notifiers ||= ::Guard::Notifier.notifiers
  end

  config.after(:each) do
    Guard::Notifier.clear_notifiers

    Guard.clear_options
  end

  config.after(:all) do
    ENV["GUARD_NOTIFY"] = @guard_notify
    ::Guard::Notifier.notifiers = @guard_notifiers
  end

end
