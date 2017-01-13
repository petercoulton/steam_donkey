require 'aws-sdk'
require 'to_regexp'
require_relative '../../../lib/steam_donkey/cli/output'
require 'command_line_reporter'
require_relative 'resource_listing.rb'
require 'colorize'

module SteamDonkey
  module AWS
    module CF
      class Stacks
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
          cf = Aws::CloudFormation::Client.new
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
            raise "Unknown column,#{column[:name]}"
          end
        end
      end

      class Exports
        include SteamDonkey::AWS::ResourceListing

        def aliases
          [
              { test: /^StackId$/i, value: 'ExportingStackId' }
          ]
        end

        def search
          cf         = Aws::CloudFormation::Client.new
          result     = []
          exports    = cf.list_exports
          begin
            last_token = exports.next_token
            exports.exports.map do |export|
              result << export
            end
            exports = cf.list_exports({ :next_token => exports.next_token })
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

      class Events
        BOLD     = "[1m"
        BLACK    = "[30m"
        RED      = "[31m"
        GREEN    = "[32m"
        YELLOW   = "[33m"
        BLUE     = "[34m"
        MAGENTA  = "[35m"
        CYAN     = "[36m"
        WHITE    = "[37m"

        def status_colors
          {
            "REVIEW_IN_PROGRESS"                           => "\033" + YELLOW,

            "CREATE_IN_PROGRESS"                           => "\033" + YELLOW,
            "CREATE_FAILED"                                => "\033" + RED,
            "CREATE_COMPLETE"                              => "\033" + GREEN,
            
            "DELETE_IN_PROGRESS"                           => "\033" + RED,
            "DELETE_FAILED"                                => "\033" + RED,
            "DELETE_COMPLETE"                              => "\033" + BOLD,
            "DELETE_SKIPPED"                               => "\033" + BOLD,

            "UPDATE_IN_PROGRESS"                           => "\033" + YELLOW,
            "UPDATE_FAILED"                                => "\033" + RED,
            "UPDATE_COMPLETE"                              => "\033" + GREEN,
            "UPDATE_COMPLETE_CLEANUP_IN_PROGRESS"          => "\033" + YELLOW,

            "UPDATE_ROLLBACK_IN_PROGRESS"                  => "\033" + RED,
            "UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS" => "\033" + RED,
            "UPDATE_ROLLBACK_COMPLETE"                     => "\033" + GREEN
          }
        end

        def initialize(options)
          @options = options
          @events_seen = []
          @widest_status = 0
        end

        def list
          puts @options[:since]
          printf("%s%-20s  %-44s  %-26s  %s%s\n",
            "\033[1m", 
            "Timestamp",
            "Status",
            "Resource Type",
            "Logical Id",
            "\033[0m"
          )

          trap("SIGINT") { throw :ctrl_c }
          catch :ctrl_c do
            begin
              events = []
              stack_events.each do |response|
                new_events(response).each do |event|
                  @events_seen << event.event_id
                  if after_desired_time(event)
                    events.unshift event
                  end
                end
              end
              print_events(events)
              sleep 5 if @options[:follow]
            end while @options[:follow]
          end
        end

        def after_desired_time(event)
          event.timestamp > @options[:since]
        end

        def stack_name
          @options[:stack_name]
        end

        def cf_client
          @cf_client ||= Aws::CloudFormation::Client.new
        end

        def stack_events
          cf_client.describe_stack_events(:stack_name => stack_name)
        end

        def new_events(response)
          response.stack_events.select(&self.method(:is_new?))
        end

        def is_new?(event) 
          !@events_seen.include? event.event_id
        end

        def print_events(events)
          events.each do |event|
            # puts "#{event.timestamp.iso8601}"
            printf("%-20s  %s%-44s%s  %-26s  %s\n",
                event.timestamp.iso8601,
                status_colors[event.resource_status], event.resource_status, "\033[0m",
                event.resource_type,
                event.logical_resource_id
            )
          end
          STDOUT.flush
        end

      end
    end
  end
end




