require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'rdoc/task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

RDoc::Task.new do |rdoc|
  rdoc.main = 'lib/tree/red_black.rb'
  rdoc.options << '--markup'
end
