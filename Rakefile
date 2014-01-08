Encoding.default_internal = 'UTF-8'
require 'rubygems'
require 'rake/testtask'
Bundler.require

require './env.rb'

namespace :db do
  task :bootstrap do
    DataMapper.auto_migrate!
  end

  task :migrate do
    DataMapper.auto_upgrade!
  end
end
