require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "sweat_shop"
    s.summary = %Q{SweatShop is a simple asynchronous worker queue build on top of rabbitmq/ampq}
    s.email = "amos@geni.com"
    s.homepage = "http://github.com/famoseagle/sweat-shop"
    s.description = "TODO"
    s.authors = ["Amos Elliston"]
    s.files =  FileList["[A-Z]*", "{lib,test,config}/**/*"]
    s.add_dependency('famoseagle-carrot', '= 0.7.0')
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::TestTask.new

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'new_project'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Rcov::RcovTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :default => :test

task :setup do
  require File.dirname(__FILE__) + '/install'
end
