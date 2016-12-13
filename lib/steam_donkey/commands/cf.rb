require 'steam_donkey/aws/cf'

module SteamDonkey
  class Cf < Thor
    include Thor::Actions
    default_task :list

    desc 'list', 'List cloudformation stacks'
    method_option :raw, :aliases => '-r', :default => false, :desc => 'Toggle to display headings', :type => :boolean
    method_option :render_headings, :aliases => '-h', :default => true, :desc => 'Toggle to display headings', :type => :boolean
    method_option :format, :aliases => '-o', :default => 'pretty', :desc => 'Output format', :enum => %w(pretty raw)
    method_option :columns, :aliases => '-c', :default => 'Name,CreationTime,Status', :desc => 'Columns to display'
    method_option :filter_columns, :aliases => '-f', :default => '', :desc => 'Filters to apply'
    method_option :sort, :aliases => '-s', :default => 'CreationTime=desc,Name', :desc => 'Columns to sort by'
    map :ls => :list
    def list
      show_headings = options[:render_headings]
      format        = options[:format]
      if options[:raw]
        show_headings = false
        format        = 'raw'
      end
      # begin
      stacks   = SteamDonkey::AWS::CF::Listing.new(options[:filter_columns], options[:columns], options[:sort])
      output = SteamDonkey::Cli::Output.new(show_headings, format)
      output.render(stacks.column_labels, stacks.list)
      # rescue Exception => msg
      #   help
      #   puts "Error: #{msg}"
      #   exit 1
      # end
    end
  end
end
