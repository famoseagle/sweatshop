require 'fileutils'
root = File.dirname(__FILE__)

unless defined?(RAILS_ROOT)
  search_paths = %W{/.. /../.. /../../..}
  search_paths.each do |path|
    if File.exist?(root + path + '/config/environment.rb') 
      RAILS_ROOT = root + path 
      break
    end
  end
end
return unless RAILS_ROOT

config = 'sweatshop.yml'
script = 'sweatshop'

FileUtils.cp(File.join(root, 'config', config), File.join(RAILS_ROOT, 'config', config))
FileUtils.cp(File.join(root, 'script', script), File.join(RAILS_ROOT, 'script', script))
puts "\n\ninstalled #{ [config, script].join(", ") } \n\n"
