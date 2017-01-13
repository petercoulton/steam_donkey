# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'steam_donkey/version'

Gem::Specification.new do |spec|
  spec.name          = 'steam_donkey'
  spec.version       = SteamDonkey::VERSION
  spec.authors       = ['Peter Coulton']
  spec.email         = ['petercoulton@gmail.com']

  spec.summary       = 'Write a longer description or delete this line.'
  spec.description   = 'Write a longer description or delete this line.'
  spec.homepage      = 'http://github.com/petercoulton/steam-donkey'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'


  spec.add_dependency 'thor', '~> 0.19'
  spec.add_dependency 'aws-sdk', '~> 2.6'
  spec.add_dependency 'to_regexp', '~> 0.2.1'
  spec.add_dependency 'command_line_reporter', '~> 3.0'
  spec.add_dependency 'colorize', '~> 0.8'
  spec.add_dependency 'chronic', '~> 0.10'
  spec.add_dependency 'commander', '~> 4'
end
