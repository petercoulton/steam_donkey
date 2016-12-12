require 'steam_donkey/aws/sg'

module SteamDonkey
  class Sg < Thor
    include Thor::Actions
    default_task :list

    desc 'list', 'List security groups'
    method_option :raw, :aliases => '-r', :default => false, :desc => 'Toggle to display headings', :type => :boolean
    method_option :render_headings, :aliases => '-h', :default => true, :desc => 'Toggle to display headings', :type => :boolean
    method_option :format, :aliases => '-o', :default => 'pretty', :desc => 'Output format', :enum => %w(pretty raw)
    method_option :columns, :aliases => '-c', :default => 'Id,Name,VpcId', :desc => 'Columns to display'
    method_option :filter_columns, :aliases => '-f', :default => '', :desc => 'Filters to apply'
    method_option :sort, :aliases => '-s', :default => 'VpcId,Name', :desc => 'Columns to sort by'
    map :ls => :list
    def list
      show_headings = options[:render_headings]
      format        = options[:format]
      if options[:raw]
        show_headings = false
        format        = 'raw'
      end
      # begin
      vpcs   = SteamDonkey::AWS::SG::Listing.new(options[:filter_columns], options[:columns], options[:sort])
      output = SteamDonkey::Cli::Output.new(show_headings, format)
      output.render(vpcs.column_labels, vpcs.list)
      # rescue Exception => msg
      #   help
      #   puts "Error: #{msg}"
      #   exit 1
      # end
    end
  end
end
