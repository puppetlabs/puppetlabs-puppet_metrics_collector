source "https://rubygems.org"

group :test do
  gem "rake", ">= 10.1"
  gem "beaker", "~> 3.0"
  gem "beaker-abs", "~> 0.2"
  gem "beaker-pe", "~> 1.11"
  gem "puppet", ENV['PUPPET_VERSION'] || "~> 4.5"
  gem "rspec", "~> 3.4"
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
