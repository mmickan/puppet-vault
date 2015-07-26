require 'simplecov'
SimpleCov.start do
    add_filter '/spec/'
    add_filter '/pkg/'
    add_filter '/.vendor/'
end

require 'puppetlabs_spec_helper/module_spec_helper'

require 'rspec-puppet'
fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))
RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
end
