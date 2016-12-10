
module SteamDonkey
  class Cloudformation < Thor
    include Thor::Actions

    default_task :list

    desc "delete", "List ec2 instances"
    map :rm => :delete
    def rm
      require 'steam_donkey/aws/cloudformation'
      SteamDonkey::AWS::Cloudformation.delete stack_name
    end
  end
end
