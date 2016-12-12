require 'aws-sdk'
require 'to_regexp'
require_relative '../../../lib/steam_donkey/cli/output'
require 'command_line_reporter'

module SteamDonkey
  module AWS
    module VPC
      class Listing
        include SteamDonkey::AWS::ResourceListing

        def aliases
          [
              { test: /^Name$/i, value: 'Tags.Name' },
              { test: /^Id$/i, value: 'VpcId' }
          ]
        end

        def search
          ec2  = Aws::EC2::Client.new
          vpcs = []
          ec2.describe_vpcs.each do |response|
            response.vpcs.each do |vpc|
              vpcs << vpc
            end
          end
          vpcs
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