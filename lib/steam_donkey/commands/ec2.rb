require 'steam_donkey/aws/ec2'

module SteamDonkey
  class Ec2 < Thor
    include Thor::Actions
    default_task :list

    desc 'list', 'List ec2 instances'
    method_option :raw,      :aliases => '-r', :default => false,    :desc => 'Toggle to display headings', :type => :boolean
    method_option :render_headings, :aliases => '-h', :default => true, :desc => 'Toggle to display headings', :type => :boolean
    method_option :format,   :aliases => '-o', :default => 'pretty', :desc => 'Output format', :enum => %w(pretty raw)
    method_option :columns,  :aliases => '-c', :default => 'Name,PublicIpAddress,KeyName,Tags.OS,Tags.environment', :desc => 'Columns to display'
    method_option :filters,  :aliases => '-f', :default => 'State=running',   :desc => 'Filters to apply'
    method_option :sort,     :aliases => '-s', :default => 'LaunchTime=desc', :desc => 'Columns to sort by'
    map :ls => :list
    def list
      headings = options[:render_headings]
      format = options[:format]
      if options[:raw]
        headings = false
        format = 'raw'
      end
      begin
        SteamDonkey::AWS::EC2::Listing.new(headings, format, options[:filters], options[:columns], options[:sort]).list
      rescue Exception => msg
        help
        puts "Error: #{msg}"
        exit 1
      end
    end
  end
end
