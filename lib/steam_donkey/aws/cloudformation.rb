require 'aws-sdk'
require_relative '../../../lib/steam_donkey/cli/listing'

module SteamDonkey
  module AWS
    module Cloudformation
      class Listing
        include CommandLineReporter

        def initialize(headings, format, filters = '', columns = '', sort = '')
          @render_headings = headings
          @format          = format
          @sort_columns    = parse_sort_columns sort || ''
          @filters         = parse_filters filters || ''
          @columns         = required_columns(parse_columns columns || '')
          @columns_labels  = (columns || '').split(',')

          self.class.send(:include, CommandLineReporter) if @format == 'pretty'
        end

        def list
          listing = SteamDonkey::Cli::Listing.new @render_headings, @format
          listing.render @columns_labels, search
        end

        def search
          stacks
              .sort_by { |a| sort_stacks(a) }
              .map(&self.method(:select_columns))
              .reject(&self.method(:filtered_out?))
              .map { |i| i.select { |c| c.has_key? :label } }
        end

        def stacks
          cf     = Aws::CloudFormation::Client.new
          stacks = []
          cf.describe_stacks.each do |response|
            response.stacks.each do |stack|
              stacks << stack
            end
          end
          stacks
        end

        def parse_sort_columns(sort_columns)
          sort_column_map = []
          sort_columns.split(',').map(&:strip).each do |filter|
            column, sort_direction = filter.split('=')
            name                   = case column
                                       when /^Name$/i
                                         'Tags.Name'
                                       when /^Id$/i
                                         'InstanceId'
                                       when /^State(\.Name)?$/i
                                         'State.Name'
                                       else
                                         column
                                     end
            sort                   = (sort_direction || 'asc').downcase
            raise "Unknown sort modifier #{sort_direction}" unless %w(asc desc).include? sort

            sort_column_map << { :name => name, :direction => sort }
          end
          sort_column_map
        end

        def select_columns(instance)
          columns = []
          @columns.each do |column|
            columns << select_column(column, instance)
          end
          columns
        end

        def select_column(column, stack)
          c = column.clone
          begin
            case column[:name]
              when /^Tags\./i
                c[:value] = find_tag(stack, column[:name].split('.').last)
              when /^State(\.Name)?$/i
                c[:value] = stack.stack_status
              when /^State\.Code$/i
                c[:value] = stack.state.code
              else
                c[:value] = stack.send(column[:name].underscore)
            end
          rescue
            raise "Unknown column #{column[:name]}"
          end
          c
        end

        def max_width(results, label)
          results.map do |result|
            value = result.detect { |f| f[:label] == label }[:value]
            if value.nil?
              0
            elsif value.is_a? Time
              value.iso8601.to_s.length
            else
              value.to_s.length
            end
          end.max
        end

        def sort_stacks(a)
          return [] if a.nil?
          @sort_columns.map do |sort|
            value = select_column(sort, a)[:value] || ''
            if sort[:direction] == 'desc'
              value = value.dup.extend(ReversedOrder)
            end
            value
          end
        end

        def remove_filter_fields(instance)
          instance.select { |c| !c.has_key? :test }
        end

        def required_columns(columns)
          result = []
          columns.each do |column|
            result << column
          end

          @filters.each do |key|
            result << key
          end

          @sort_columns.each do |key|
            result << key
          end

          result
        end

        def names(columns)
          columns.map do |column|
            column[:name]
          end
        end

        def find_tag(stack, column)
          name = column.downcase
          tag  = stack.tags.find { |tag| tag.key.downcase == name }
          if tag != nil
            tag[:value]
          else
            nil
          end
        end

        def filtered_out?(instance)
          filters = instance.select { |c| c.has_key? :test }
          skip    = false
          filters.each do |filter|
            if filter[:test] =~ /^\?.+/
              expected_value_regexp = filter[:test][1..-1].to_regexp
              skip                  = true unless !!(filter[:value] =~ expected_value_regexp)
              next
            end

            if filter[:test] =~ /^!.+/
              expected_value_regexp = filter[:test][1..-1].to_regexp
              skip                  = true if !!(filter[:value] =~ expected_value_regexp)
              next
            end

            if filter[:value] != filter[:test]
              skip = true
            end
          end
          skip
        end

        def parse_filters(filters='')
          filter_map = []
          filters.split(',').map(&:strip).each do |filter|
            column, test = filter.split('=')
            name         = case column
                             when /^Name$/i
                               'StackName'
                             when /^Id$/i
                               'InstanceId'
                             when /^State(\.Name)?$/i
                               'State.Name'
                             else
                               column
                           end

            filter_map << { :name => name, :test => test }
          end
          filter_map
        end

        def parse_columns(columns='')
          column_map = []
          columns.split(',').map(&:strip).each do |column|
            if column =~ /^Name$/i
              column_map << { :name => 'Tags.Name', :label => column }
              next
            end

            if column =~ /^Id$/i
              column_map << { :name => 'InstanceId', :label => column }
              next
            end

            if column =~ /^State(\.Name)?$/i
              column_map << { :name => 'State.Name', :label => column }
              next
            end

            column_map << { :name => column, :label => column }
          end
          column_map
        end
      end
    end
  end
end