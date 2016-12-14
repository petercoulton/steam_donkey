require 'aws-sdk'
require 'to_regexp'
require_relative '../../../lib/steam_donkey/cli/output'
require 'command_line_reporter'
require_relative 'resource_listing.rb'


module SteamDonkey
  module AWS
    module EC2
      class Listing

        include SteamDonkey::AWS::ResourceListing

        attr_reader :column_labels

        def aliases
          [
              { test: /^Name$/i, value: 'Tags.Name' },
              { test: /^Id$/i, value: 'InstanceId' },
              { test: /^State(\.Name)?$/i, value: 'State.Name' }
          ]
        end

        def search
          ec2       = Aws::EC2::Client.new
          ec2.describe_instances.map do |response|
            response.reservations.map do |reservation|
              reservation.instances.map do |instance|
                instance
              end
            end.flatten
          end.flatten
        end

        def select_column(column, instance)
          c = column.clone
          begin
            case column[:name]
              when /^Tags\./i
                c[:value] = find_tag(instance, column[:name].split('.').last)
              when /^State(\.Name)?$/i
                c[:value] = instance.state.name
              when /^State\.Code$/i
                c[:value] = instance.state.code
              else
                c[:value] = instance.send(column[:name].underscore)
            end
          rescue
            raise "Unknown column #{column[:name]}"
          end
          c
        end
      end
    end
  end
end