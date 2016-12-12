require 'aws-sdk'
require 'to_regexp'
require_relative '../../../lib/steam_donkey/cli/output'
require 'command_line_reporter'
require_relative 'resource_listing.rb'

module SteamDonkey
  module AWS
    module CF
      class Listing
        include SteamDonkey::AWS::ResourceListing

        def aliases
          [
              { test: /^Id$/i, value: 'StackId' },
              { test: /^Name$/i, value: 'StackName' },
              { test: /^Status/i, value: 'StackStatus' },
              { test: /^StatusReason/i, value: 'StackStatusReason' },
          ]
        end

        def search
          cf  = Aws::CloudFormation::Client.new
          cf.describe_stacks.map do |response|
            response.stacks.map do |stack|
              stack
            end
          end.flatten
        end

        def select_column(column, stack)
          begin
            c = column.clone
            case column[:name]
              when /^Tags\./i
                c[:value] = find_tag(stack, column[:name].split('.').last)
              else
                c[:value] = stack.send(column[:name].underscore)
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