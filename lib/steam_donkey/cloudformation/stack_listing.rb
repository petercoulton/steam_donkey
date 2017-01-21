require 'aws-sdk'

module SteamDonkey
  module Cloudformation
    class StackListing
      include SteamDonkey::ResourceListing

      def initialize(client, options = {})
        @client = client
        init(options[:sort], options[:filters], options[:columns])
      end

      def aliases
          [
              { test: /^Id$/i, value: 'StackId' },
              { test: /^Name$/i, value: 'StackName' },
              { test: /^Status/i, value: 'StackStatus' },
              { test: /^StatusReason/i, value: 'StackStatusReason' },
          ]
        end

        def search
          @client.list_stacks.map do |response|
            response.stack_summaries.map do |stack|
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
            raise "Unknown column,#{column[:name]}"
          end
        end
      
    end
  end
end