require 'thor'
require 'steam_donkey/cli/ec2'
require 'steam_donkey/cli/cloudformation'

module SteamDonkey
  class CLI < Thor
    include Thor::Actions

    desc 'config', 'Create default steam donkey config'
    def config
      puts 'configurating...done'
    end

    register(Ec2, 'ec2', 'ec2', 'Manage EC2 instances')
    register(Cloudformation, 'cloudformation', 'cloudformation', 'Manage EC2 instances')
  end
end