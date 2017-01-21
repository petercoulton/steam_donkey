# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','steam_donkey','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'steam_donkey'
  s.version = SteamDonkey::VERSION
  s.author = 'Peter Coulton'
  s.email = 'petercoulton@gmail.com'
  s.homepage = 'https://github.com/petercoulton/steam_donkey'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Tools and scripts for building and managing infrastructure on AWS.'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','steam_donkey.rdoc']
  s.rdoc_options << '--title' << 'steam_donkey' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'donkey'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','2.14.0')
  s.add_runtime_dependency('aws-sdk', '~> 2.6')
  s.add_runtime_dependency('chronic', '~> 0.10')
  s.add_runtime_dependency('to_regexp', '~> 0.2.1')
  s.add_runtime_dependency('command_line_reporter', '~> 3.0')
end
