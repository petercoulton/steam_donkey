require 'aws-sdk'

module SteamDonkey
  module Cloudformation
    class ExportsListing
      include SteamDonkey::ResourceListing

      def initialize(client, options = {})
        @client = client
        init(options[:sort], options[:filters], options[:columns])
      end

      def aliases
        [
          { test: /^StackId$/i, value: 'ExportingStackId' }
        ]
      end

      def search
        result     = []
        exports    = @client.list_exports
        begin
          last_token = exports.next_token
          exports.exports.map do |export|
            result << export
          end
          exports = @client.list_exports({ :next_token => exports.next_token })
        end while last_token != exports.next_token

        result
      end

      def select_column(column, stack)
        begin
          c = column.clone
          case column[:name]
            when 'nil'
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