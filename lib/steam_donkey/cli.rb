require 'thor'
require 'steam_donkey/commands/ec2'
require 'steam_donkey/commands/vpc'
require 'steam_donkey/commands/sg'
require 'steam_donkey/commands/cf'

module SteamDonkey
  class CLI < Thor
    include Thor::Actions
    register(Ec2, 'ec2', 'ec2', 'Manage EC2 instances')
    register(Vpc, 'vpc', 'vpc', 'Manage VPCs')
    register(Sg, 'sg', 'sg', 'Manage Security Groups')
    register(Cf, 'cf', 'cf', 'Manage Cloudformation stacks')
  end
end