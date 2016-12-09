require 'aws-sdk'
require 'to_regexp'

class String
  def underscore
    self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
  end
end

module SteamDonkey
  module AWS

    class EC2Listing
      def initialize(filters = '', columns = '', sort = '')
        @filters = parse_filters filters || ''
        @columns = parse_columns columns || ''
      end

      def list
        rows.each do |row|
          puts row.map { |c| c[:value] }.join(',')
        end
      end

      def rows
        results = []
        instances.each do |instance|
          row = []
          required_columns.each do |column|
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
            row << c
          end
          results << remove_filter_fields(row) unless filtered_out? row
        end
        results
      end

      def remove_filter_fields instance
        instance.select { |c| !c.has_key? :test }
      end

      def required_columns
        result = []
        @columns.each do |column|
          result << column
        end

        @filters.each do |key|
          result << key
        end
        result
      end

      def names columns
        columns.map do |column|
          column[:name]
        end
      end

      def find_tag(instance, column)
        name = column.downcase
        tag = instance.tags.find { |tag| tag.key.downcase == name }
        if tag != nil
          tag[:value]
        else
          nil
        end
      end

      def instances
        ec2 = Aws::EC2::Client.new
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

      def filtered_out? instance
        filters = instance.select { |c| !c[:test].nil? }
        skip = false
        filters.each do |filter|
          if filter[:test] =~ /^\?.+/
            expected_value_regexp = filter[:test][1..-1].to_regexp
            skip = true unless !!(filter[:value] =~ expected_value_regexp)
            next
          end

          if filter[:test] =~ /^!.+/
            expected_value_regexp = filter[:test][1..-1].to_regexp
            skip = true if !!(filter[:value] =~ expected_value_regexp)
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
          name = case column
            when /^Name$/i
              'Tags.Name'
            when /^Id$/i
              'InstanceId'
            when /^State(\.Name)?$/i
              'State.Name'
            else
              column
          end

          filter_map << {:name => name, :test => test }
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