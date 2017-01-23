require 'chronic'

desc 'Manage and view cloudformation stacks and templates'
command [:cf] do |cf|

  cf.desc 'List cloudformation stacks'
  cf.command [:list, :ls] do |list|

  	list.switch [:raw,      :r], :default_value => false, :negatable => false, :desc => "Output unformatted, useful when piping results to other commands"
  	list.switch [:headings, :h], :default_value => false, :desc => "Toggle column headings"

    list.flag [:filters, :f], :default_value => 'Status=!/DELETE_COMPLETE/', :desc => ""
    list.flag [:columns, :c], :default_value => 'Name,CreationTime,Status', :desc => ""
  	list.flag [:sort,    :s], :default_value => 'CreationTime=desc,Name', :desc => ""

    list.flag [:output, :o], :default_value => 'pretty', :must_match => { "pretty"  => :pretty, "raw" => :raw }

    list.action do |global_options, options, args|
      listing_options = {
        :filters => options[:filters],
        :columns => options[:columns],
        :sort    => options[:sort]
      }

      stack_listing = SteamDonkey::Cloudformation::StackListing.new(cf_client(global_options), listing_options)

      output = SteamDonkey::Cli::Output.new true, options[:output]
      output.render stack_listing.column_labels, stack_listing.list
    end
  end

  cf.desc 'List stack events'
  cf.command [:events] do |events|

    events.flag ['stack-name', :s], :arg_name => 'STACK_NAME', :required => true,  :desc => "Stack name"
    events.switch ['follow', :f],   :default_value => false,   :negatable => false

    events.action do |global_options, options, args|  
      list_options = {
        :follow     => options[:follow],
        :stack_name => options[:'stack-name'],
        :since      => Chronic.parse("2 years ago")
      }

      event_log = SteamDonkey::Cloudformation::EventLog.new(cf_client(global_options), list_options)
      event_log.list
    end
  end

  cf.desc 'List cloudformation exports'
  cf.command [:exports] do |exports|

    exports.switch [:raw,      :r], :default_value => false, :negatable => false, :desc => "Output unformatted, useful when piping results to other commands"
    exports.switch [:headings, :h], :default_value => false, :desc => "Toggle column headings"

    exports.flag [:filters, :f], :default_value => '', :desc => ""
    exports.flag [:columns, :c], :default_value => 'Name,Value', :desc => ""
    exports.flag [:sort,    :s], :default_value => 'Name', :desc => ""

    exports.flag [:output, :o], :default_value => 'pretty', :must_match => { "pretty"  => :pretty, "raw" => :raw }

    exports.action do |global_options, options, args|
      listing_options = {
        :filters => options[:filters],
        :columns => options[:columns],
        :sort    => options[:sort]
      }

      exports_listing = SteamDonkey::Cloudformation::ExportsListing.new(cf_client(global_options), listing_options)

      output = SteamDonkey::Cli::Output.new true, options[:output]
      output.render exports_listing.column_labels, exports_listing.list
    end
  end

  cf.desc 'Package cloudformation template and upload to S3'
  cf.arg_name 'template_path'
  cf.command [:package] do |p|

    p.flag [:bucket, :b], :desc => "Name of the S3 bucket to upload packaged templates to"
    p.flag [:prefix, :p], :desc => "Prefix to prepend to uploaded templates"
    p.flag [:template, :t], :desc => "Path to template to package and upload"

    p.action do |global_options, options, args|
      bucket_name = options[:bucket] || global_options[:rc][:cloudformation][:package]["bucketName"]
      bucket_path_prefix = options[:prefix] || global_options[:rc][:cloudformation][:package]["bucketPathPrefix"]

      package = SteamDonkey::Cloudformation::Package.new(s3_client(global_options), global_options[:verbose])

      package.package options[:template], bucket_name, bucket_path_prefix
    end
  end
end

