Gem::Specification.new do |s|
  s.name = %q{sweat_shop}
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Amos Elliston"]
  s.date = %q{2009-08-26}
  s.default_executable = %q{sweatd}
  s.description = %q{TODO}
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
     "lib/message_queue/base.rb",
     "lib/message_queue/kestrel.rb",
     "lib/message_queue/rabbit.rb",
     "lib/sweat_shop.rb",
     "lib/sweat_shop/daemoned.rb",
     "lib/sweat_shop/metaid.rb",
     "lib/sweat_shop/sweatd.rb",
     "lib/sweat_shop/worker.rb",
     "test/hello_worker.rb",
     "test/test_functional_worker.rb",
     "test/test_helper.rb",
     "test/test_sweatshop.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/famoseagle/sweat-shop}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{SweatShop is a simple asynchronous worker queue build on top of rabbitmq/ampq}
  s.test_files = [
    "test/hello_worker.rb",
     "test/test_functional_worker.rb",
     "test/test_helper.rb",
     "test/test_sweatshop.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<famoseagle-carrot>, ["= 0.7.0"])
    else
      s.add_dependency(%q<famoseagle-carrot>, ["= 0.7.0"])
    end
  else
    s.add_dependency(%q<famoseagle-carrot>, ["= 0.7.0"])
  end
end
