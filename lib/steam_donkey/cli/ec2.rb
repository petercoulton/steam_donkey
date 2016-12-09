module SteamDonkey
  class Ec2 < Thor
    package_name "ec2"
    default_task :list

    desc "list", "List ec2 instances"
    map :ls => :list
    method_option :columns, :aliases => '-c', :desc => 'Columns to display'
    method_option :filters, :aliases => '-f', :desc => 'Filters to apply'
    method_option :sort,    :aliases => '-s', :desc => 'Columns to sort by'
    def list
      require 'steam_donkey/aws/ec2'
      SteamDonkey::AWS::EC2Listing.new(options[:filters], options[:columns], options[:sort]).list
    end
  end
end