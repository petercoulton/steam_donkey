desc 'Manage and view ec2 instances'
command [:ec2] do |ec2|
  
  ec2.desc 'List ec2 instances'
  ec2.command [:list, :ls] do |list|
    
  	list.switch [:raw,      :r], :default_value => false, :negatable => false, :desc => "Output unformatted, useful when piping results to other commands"
  	list.switch [:headings, :h], :default_value => false, :desc => "Toggle column headings"

    list.flag [:filter,  :f], :default_value => 'State=running'
    list.flag [:columns, :c], :default_value => 'Name,KeyName,Tags.environment,Tags.Owner,PublicIpAddress'
  	list.flag [:sort,    :s], :default_value => 'LaunchTime=desc'

    list.flag [:output, :o], :default_value => 'pretty', :must_match => %w(pretty raw)

    list.action do |global_options, options, args|
      listing_options = {
        :filters => options[:filters],
        :columns => options[:columns],
        :sort    => options[:sort]
      }

      instance_listing = SteamDonkey::EC2::InstanceListing.new(ec2_client(global_options), listing_options)

      output = SteamDonkey::Cli::Output.new(true, options[:output])
      output.render instance_listing.column_labels, instance_listing.list
    end
  end
end
