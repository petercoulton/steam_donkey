module SteamDonkey
  module Cloudformation
    class EventLog

        def initialize(client, options)
          @client = client
          @options = options
          @events_seen = []
        end

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

        def list
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

        def stack_events
          @client.describe_stack_events(:stack_name => stack_name)
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