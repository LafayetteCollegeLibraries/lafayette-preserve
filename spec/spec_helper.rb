require File.expand_path("../../config/environment", __FILE__)

require 'coveralls'
Coveralls.wear!

ENV["RAILS_ENV"] ||= 'test'
require "bundler/setup"

def coverage_needed?
  (!ENV['RAILS_VERSION'] || ENV['RAILS_VERSION'].start_with?('5.0')) &&
    (ENV['COVERAGE'] || ENV['TRAVIS'])
end

if coverage_needed?
  require 'simplecov'
  SimpleCov.root(File.expand_path('../..', __FILE__))
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start('rails') do
    add_filter '/.internal_test_app'
    add_filter '/lib/generators'
    add_filter '/spec'
  end
  SimpleCov.command_name 'spec'
end

require 'factory_girl'
require 'database_cleaner'

require 'devise'
require 'devise/version'
require 'mida'
require 'rspec/matchers'
require 'equivalent-xml/rspec_matchers'
require 'rails-controller-testing' if Rails::VERSION::MAJOR >= 5
require 'rspec/its'
require 'rspec/rails'
require 'rspec/active_model/mocks'
require 'capybara/poltergeist'
require 'capybara/rspec'
require 'capybara/rails'


require 'byebug' unless ENV['TRAVIS']
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

Capybara.default_driver = :rack_test      # This is a faster driver
Capybara.javascript_driver = :poltergeist # This is slower
Capybara.default_max_wait_time = ENV['TRAVIS'] ? 30 : 15

ActiveJob::Base.queue_adapter = :inline

if ENV['TRAVIS'] == 'true'
  # Monkey-patches the FITS runner to return the PDF FITS fixture
  module Hydra::Works
    class CharacterizationService
      def self.run(_, _)
        raise "FITS!!!"
        # return unless file_set.original_file.has_content?
        # filename = ::File.expand_path("../fixtures/pdf_fits.xml", __FILE__)
        # file_set.characterization.ng_xml = ::File.read(filename)
      end
    end
  end
end

if defined?(ClamAV)
  ClamAV.instance.loaddb
else
  class ClamAV
    include Singleton
    def scanfile(_f)
      0
    end

    def loaddb
      nil
    end
  end
end

FactoryGirl.definition_file_paths = [File.expand_path("../factories", __FILE__)]
FactoryGirl.find_definitions

require 'shoulda/matchers'
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
  end
end

require 'active_fedora/cleaner'
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.use_transactional_fixtures = false

  config.before :suite do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before :each do |example|
    unless example.metadata[:type] == :view || example.metadata[:no_clean]
      ActiveFedora::Cleaner.clean!
    end
  end

  config.before :each do |example|
    if example.metadata[:type] == :feature && Capybara.current_driver != :rack_test
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    end
  end

  config.after do
    DatabaseCleaner.clean
  end

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.include Shoulda::Matchers::Independent

  if Devise::VERSION >= '4.2'
    # This is for an unreleased version of Devise (will either be 4.2 or 5.0)
    config.include Devise::Test::ControllerHelpers, type: :controller
  else
    config.include Devise::TestHelpers, type: :controller
  end

  # config.include RailsRoutes
  config.include Rails.application.routes.url_helpers

  config.include Warden::Test::Helpers, type: :feature
  config.after(:each, type: :feature) { Warden.test_reset! }

  config.include Capybara::RSpecMatchers, type: :input
  config.include FactoryGirl::Syntax::Methods

  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.order = :random
  Kernel.srand config.seed

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run_when_matching :focus

  config.example_status_persistence_file_path = 'spec/examples.txt'

  config.profile_examples = 10
end
