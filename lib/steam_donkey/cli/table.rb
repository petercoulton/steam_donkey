module SteamDonkey
  module Cli
    class Table
      attr_reader :headings

      def initialize(headings: [])
        @rows = []
      end

      def headings=(headings = [])
        @headings = Row.new headings
      end

      def add_row(row)
        @rows << row
      end
      alias << add_row

      def render
        buffer = []
        @headings.each do |heading|
            buffer << heading.value
        end
        buffer.join(',')
      end
      alias :to_s :render
    end

    class Row
      def initialize values
        @cells = values.map {|h| Cell.new h }
      end
    end

    class Cell
      attr_reader :value
      def initialize(value)
        @value = value
      end
    end
  end
end
