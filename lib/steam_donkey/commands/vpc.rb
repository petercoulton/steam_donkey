require 'steam_donkey/aws/vpc'

module SteamDonkey
  class Vpc < Thor
    include Thor::Actions
    default_task :list

    desc 'list', 'List ec2 instances'
    method_option :raw,      :aliases => '-r', :default => false,    :desc => 'Toggle to display headings', :type => :boolean
    method_option :render_headings, :aliases => '-h', :default => true, :desc => 'Toggle to display headings', :type => :boolean
    method_option :format,   :aliases => '-o', :default => 'pretty', :desc => 'Output format', :enum => %w(pretty raw)
    method_option :columns,  :aliases => '-c', :default => 'Id,Name,IsDefault,Tags.environment', :desc => 'Columns to display'
    method_option :filter_columns, :aliases => '-f', :default => 'State=available', :desc => 'Filters to apply'
    method_option :sort,     :aliases => '-s', :default => 'IsDefault=desc,Name', :desc => 'Columns to sort by'
    map :ls => :list
    def list
      show_headings = options[:render_headings]
      format = options[:format]
      if options[:raw]
        show_headings = false
        format = 'raw'
      end
  
      begin
        vpcs = SteamDonkey::AWS::VPC::Listing.new(options[:filter_columns], options[:columns], options[:sort])
        output = SteamDonkey::Cli::Output.new(show_headings, format)
        output.render(vpcs.column_labels, vpcs.list)
      rescue Exception => msg
        help
        puts "Error: #{msg}"
        exit 1
      end
    end
  end
end
