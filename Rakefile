require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
PuppetLint.configuration.fail_on_warnings = false
PuppetLint.configuration.send('disable_class_parameter_defaults')
PuppetLint.configuration.send('disable_autoloader_layout')
PuppetLint.configuration.send('disable_80chars')

exclude_paths = [
  'pkg/**/*',
  '.vendor/**/*',
  'spec/**/*',
]
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

desc 'Run syntax, lint, and spec tests'
task :test => [
  :syntax,
  :lint,
  :spec_prep,
  :spec_standalone,
]

ENV['BEAKER_set'] ||= 'ubuntu-14-04'
desc 'Run acceptance tests'
task :acceptance => [
  :spec_clean,
  :beaker,
]

desc 'Use Guard to run tests after any change'
task :guard do
  system('bundle exec guard')
end
