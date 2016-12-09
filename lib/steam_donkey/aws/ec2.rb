require 'aws-sdk'
require 'to_regexp'
require_relative '../../../lib/steam_donkey/cli/table'
require 'command_line_reporter'

class String
  def underscore
    self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
        gsub(/([a-z\d])([A-Z])/, '\1_\2').
        tr('-', '_').
        downcase
  end
end

module ReversedOrder
  def <=>(other)
    - super
  end
end

module SteamDonkey
  module AWS

    class EC2Listing
      include CommandLineReporter

      def initialize(headings, format, filters = '', columns = '', sort = '')
        @headings       = headings
        @format         = format
        @sort_columns   = parse_sort_columns sort || ''
        @filters        = parse_filters filters || ''
        @columns        = required_columns(parse_columns columns || '')
        @columns_labels = columns.split(',')

        self.class.send(:include, CommandLineReporter) if @format == 'pretty'
      end

      def parse_sort_columns sort_columns
        sort_column_map = []
        sort_columns.split(',').map(&:strip).each do |filter|
          column, sort_direction = filter.split('=')
          name         = case column
                           when /^Name$/i
                             'Tags.Name'
                           when /^Id$/i
                             'InstanceId'
                           when /^State(\.Name)?$/i
                             'State.Name'
                           else
                             column
                         end
          sort = (sort_direction || 'asc').downcase
          raise "Unknown sort modifier #{sort_direction}" unless %w(asc desc).include? sort

          sort_column_map << { :name => name, :direction => sort }
        end
        sort_column_map
      end

      def list
        results = search
        case @format
          when 'pretty'
            table do
              row :header => true  do
                @columns_labels.each do |label|
                  column label, :width => [max_width(results, label), label.length].max + 2
                end
              end

              results.each do |result|
                row do
                  @columns_labels.each do |label|
                    value = result.detect { |f| f[:label] == label }[:value]
                    value = '-' if value.nil?
                    if value.is_a? Time
                      value = value.iso8601.to_s
                    else
                      value = '-' if value.empty?
                    end
                    column value
                  end
                end
              end
            end
          else
            puts @columns_labels.join(',') if @headings
            results.each do |result|
              puts result.map { |c| c[:value] }.join(',')
            end
        end
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

      def search
        all_instances
            .sort_by { |a| sort_instances(a) }
            .map(&self.method(:select_columns))
            .reject(&self.method(:filtered_out?))
            .map {|i| i.select {|c| c.has_key? :label }}
      end

      def sort_instances(a)
        return [] if a.nil?
        @sort_columns.map do |sort|
          value = select_column(sort, a)[:value] || ''
          if sort[:direction] == 'desc'
            value = value.dup.extend(ReversedOrder)
          end
          value
        end
      end

      def select_columns(instance)
        columns = []
        @columns.each do |column|
          columns << select_column(column, instance)
        end
        columns
      end

      def select_column(column, instance)
        c = column.clone
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
        c
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

      def find_tag(instance, column)
        name = column.downcase
        tag  = instance.tags.find { |tag| tag.key.downcase == name }
        if tag != nil
          tag[:value]
        else
          nil
        end
      end

      def all_instances
        ec2       = Aws::EC2::Client.new
        instances = []
        ec2.describe_instances.each do |response|
          response.reservations.each do |reservation|
            reservation.instances.each do |instance|
              instances << instance
            end
          end
        end
        instances
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
                             'Tags.Name'
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