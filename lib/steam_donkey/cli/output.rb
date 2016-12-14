require 'command_line_reporter'

module SteamDonkey
  module Cli
    class Output
      include CommandLineReporter

      def initialize(render_headings, format)
        @format = format
        @render_headings = render_headings
      end

      def render(headings, rows)
        case @format
          when 'pretty'
            table do
              row :header => true  do
                headings.each do |label|
                  column label, :width => max_width(rows, label)+ 2, :color => 'blue'
                end
              end

              rows.each do |result|
                row do
                  headings.each do |label|
                    value = result.detect { |f| f[:label] == label }[:value]
                    value = '-' if value.nil?
                    if value.is_a? Time
                      value = value.iso8601.to_s
                    else
                      value = '-' if value.methods.include? :empty? and value.empty?
                    end
                    column value
                  end
                end
              end
            end
          else
            puts headings.join(',') if @render_headings
            rows.each do |result|
              puts result.map { |c| c[:value] }.join(',')
            end
        end
      end

      def max_width(results, label)
        width = results.map do |result|
          value = result.detect { |f| f[:label] == label }[:value]
          if value.nil?
            0
          elsif value.is_a? Time
            value.iso8601.to_s.length
          else
            value.to_s.length
          end
        end
        width << label.length
        width.max
      end
    end
  end
end
