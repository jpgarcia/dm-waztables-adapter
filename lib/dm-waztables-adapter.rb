require 'rubygems'

if defined?(gem)
  gem 'dm-core', '~> 0.10.2'
  gem 'waz-storage', '~> 1.0.0'
end

require 'dm-core'
require 'waz-tables'

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'dm-waztables-adapter/version'
require 'dm-waztables-adapter/adapter'
require 'dm-waztables-adapter/migrations'