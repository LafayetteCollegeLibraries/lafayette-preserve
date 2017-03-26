#!/usr/bin/env rake

require File.expand_path('../config/application', __FILE__)
require 'bundler/setup'
require 'rspec/core'
require 'rspec/core/rake_task'
require 'solr_wrapper'
require 'solr_wrapper/rake_task'
require 'fcrepo_wrapper'
require 'engine_cart/rake_task'
require 'rubocop/rake_task'
require 'active_fedora/rake_support'

Rails.application.load_tasks

desc 'Run style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = true
end

desc 'Run specs and style checker'
task :spec do
  RSpec::Core::RakeTask.new(:spec)
end

desc 'Spin up test servers and run specs'
task :spec_with_app_load  do
  reset_statefile! if ENV['TRAVIS'] == 'true'
  with_test_server do
    Rake::Task['spec'].invoke
  end
end

task default: :spec_with_app_load
