# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sweatshop}
  s.version = "1.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Amos Elliston"]
  s.date = %q{2009-10-26}
  s.default_executable = %q{sweatd}
  s.description = %q{See summary}
  s.email = %q{amos@geni.com}
  s.executables = ["sweatd"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.markdown"
  ]
  s.files = [
    "History.txt",
     "LICENSE",
     "README.markdown",
     "Rakefile",
     "VERSION.yml",
     "config/defaults.yml",
     "config/sweatshop.yml",
     "install.rb",
     "lib/message_queue/base.rb",
     "lib/message_queue/kestrel.rb",
     "lib/message_queue/rabbit.rb",
     "lib/sweatshop.rb",
     "lib/sweatshop/daemoned.rb",
     "lib/sweatshop/metaid.rb",
     "lib/sweatshop/sweatd.rb",
     "lib/sweatshop/worker.rb",
     "script/initd.sh",
     "script/kestrel",
     "script/kestrel.sh",
     "script/sweatshop",
     "test/hello_worker.rb",
     "test/test_functional_worker.rb",
     "test/test_helper.rb",
     "test/test_sweatshop.rb"
  ]
  s.homepage = %q{http://github.com/famoseagle/sweat-shop}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Sweatshop is a simple asynchronous worker queue build on top of rabbitmq/ampq}
  s.test_files = [
    "test/hello_worker.rb",
     "test/test_functional_worker.rb",
     "test/test_helper.rb",
     "test/test_sweatshop.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<famoseagle-carrot>, ["= 0.7.0"])
    else
      s.add_dependency(%q<famoseagle-carrot>, ["= 0.7.0"])
    end
  else
    s.add_dependency(%q<famoseagle-carrot>, ["= 0.7.0"])
  end
end