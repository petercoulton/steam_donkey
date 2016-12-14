require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :install_gem do
  puts "Uninstalling steam_donkey gem"
  %x{gem uninstall steam_donkey --executables}
  puts "Building steam_donkey gem"
  %x{gem build ./steam_donkey.gemspec}
  puts "Installing steam_donkey gem"
  %x{gem install ./steam_donkey-0.1.0.gem}
end
