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
    module ResourceListing

      attr_reader :column_labels

      def initialize(filters = '', columns = '', sort = '')
        @sort_columns   = parse_sort_columns(sort, aliases)
        @filter_columns = parse_filters(filters, aliases)
        @columns        = parse_columns(columns, @filter_columns, @sort_columns, aliases)
        @column_labels  = split_columns(columns)
      end

      def substitute_aliases(column, aliases=[])
        substitute = aliases.find { |a| a[:test] =~ column }
        substitute.nil? ? column : substitute[:value]
      end

      def split_columns(columns)
        columns.split(',').map(&:strip)
      end

      def combine_columns(columns, filter_columns, sort_columns)
        result = []
        columns.each do |column|
          result << column
        end

        filter_columns.each do |key|
          result << key
        end

        sort_columns.each do |key|
          result << key
        end

        result
      end

      def parse_columns(columns='', filter_columns = [], sort_columns = [], aliases = [])
        label_columns = split_columns(columns).map do |column|
          { :name => substitute_aliases(column, aliases), :label => column }
        end
        combine_columns(label_columns, filter_columns, sort_columns)
      end

      def parse_filters(filters='', aliases = [])
        split_columns(filters).map do |filter|
          column, test = filter.split('=')
          { :name => substitute_aliases(column, aliases), :test => test }
        end
      end

      def parse_sort_columns(sort_columns = '', aliases = [])
        split_columns(sort_columns).map do |filter|
          column, sort_direction = filter.split('=')
          sort                   = (sort_direction || 'asc').downcase

          raise "Unknown sort modifier #{sort_direction}" unless %w(asc desc).include? sort

          { :name => substitute_aliases(column, aliases), :direction => sort }
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

      def find_tag(instance, column)
        name = column.downcase
        tag  = instance.tags.find { |tag| tag.key.downcase == name }
        if tag != nil
          tag[:value]
        else
          nil
        end
      end

      def names(columns)
        columns.map do |column|
          column[:name]
        end
      end

      def remove_sort_and_filter_columns(columns)
        columns.select { |c| c.has_key? :label }
      end

      def select_columns(instance)
        columns = []
        @columns.each do |column|
          columns << select_column(column, instance)
        end
        columns
      end

      def sort_instances(instance)
        return [] if instance.nil?
        @sort_columns.map do |sort|
          value = (select_column(sort, instance)[:value] || '').to_s
          if sort[:direction] == 'desc'
            value = value.dup.extend(ReversedOrder)
          end
          value
        end
      end

      def list
        search
            .sort_by(&self.method(:sort_instances))
            .map(&self.method(:select_columns))
            .reject(&self.method(:filtered_out?))
            .map(&self.method(:remove_sort_and_filter_columns))
      end
    end
  end
end
