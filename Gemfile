source "https://rubygems.org"

group :test do
  gem "rake"
  gem "beaker"
  gem "beaker-pe", '>= 0.4.0'
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 4.1'
  gem "rspec", '< 3.2.0'
  gem "rspec-puppet", '~> 2.0'
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "rspec-puppet-facts"
  gem 'rubocop', '0.42.0'
  gem 'simplecov', '>= 0.11.0'
  gem 'simplecov-console'
end

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
