require 'aws-sdk'
require 'to_regexp'
require_relative '../../../lib/steam_donkey/cli/output'
require 'command_line_reporter'
require_relative 'resource_listing.rb'

module SteamDonkey
  module AWS
    module SG
      class Listing
        include SteamDonkey::AWS::ResourceListing

        def aliases
          [
              { test: /^Name$/i, value: 'GroupName' },
              { test: /^Id$/i, value: 'GroupId' }
          ]
        end

        def search
          ec2  = Aws::EC2::Client.new
          ec2.describe_security_groups.each do |response|
            response.security_groups.each do |group|
              group
            end
          end.flatten
        end

        def select_column(column, instance)
          begin
            c = column.clone
            case column[:name]
              when /^Tags\./i
                c[:value] = find_tag(instance, column[:name].split('.').last)
              else
                c[:value] = instance.send(column[:name].underscore)
            end
            c
          rescue
            raise "Unknown column #{column[:name]}"
          end
        end
      end
    end
  end
end