require 'pathname'

module SteamDonkey
  module Cloudformation


    class Template

      def initialize(dirname, filename)
        @dirname = dirname
        @filename = filename
      end

      def path
        File.join(@dirname, @filename)
      end

      def name
        @filename
      end

      def contains_child_templates?
        !templates.empty?
      end

      def templates
        @child_references ||= scan_for_child_templates path
      end

      def relative_path(root)
        template_path = Pathname.new(path)
        root_path = Pathname.new(root)
        template_path.relative_path_from(root_path)
      end

      def packaged_template(bucket, prefix, root_path)
        lines = []
        File.readlines(path).each do |line|
          new_line = line
          line.scan /\.\/(.+)$/ do |child_path|
            unless child_path.empty?
              new_line = line.gsub(/\.\/.+$/, "https://s3-eu-west-1.amazonaws.com/#{bucket}/#{prefix}/#{child_path.first}")
            end
          end
          lines << new_line
        end
        lines.join
      end

    private

      def scan_for_child_templates(template)
        child_templates = []
        child_templates << self
        File.readlines(template).each do |line|
          line.scan /\.\/(.+)$/ do |child_path|
            unless child_path.empty?
              child = create_child_template(child_path.first) 
              child_templates << child
              child_templates.push(*(child.templates))
            end
          end
        end
        child_templates.uniq
      end

      def create_child_template(path)
        child_path = File.join(@dirname, path)
        Template.new File.dirname(child_path), File.basename(child_path)
      end
    end

    class Package
      def initialize(client, verbose)
        @client = client
        @verbose = verbose || false 
      end

      def package(path, bucket, prefix)
        template_dir = File.dirname(File.absolute_path(path))
        template_name = File.basename(path)
        
        root_template = Template.new(template_dir, template_name)

        root_template.templates.each do |template|
          puts "Uploading s3://#{bucket}/#{prefix}/#{template.relative_path(template_dir)}" if @verbose
          # @client.put_object({
          #   body: template.packaged_template(bucket, prefix, template_dir),
          #   bucket: bucket,
          #   key: "#{prefix}/#{template.relative_path(template_dir)}"
          # })
        end

        puts "https://s3-eu-west-1.amazonaws.com/#{bucket}/#{prefix}/#{root_template.name}"

      end

    end
  end
end