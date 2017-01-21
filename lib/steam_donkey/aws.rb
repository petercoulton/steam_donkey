require 'aws-sdk'

def client_options(options)
  result = {}
  result[:profile] = options[:profile] if !options[:profile].nil?
  result[:region]  = options[:region] if !options[:region].nil?
  result
end

def cf_client(options)
  Aws::CloudFormation::Client.new(client_options(options))
end

def ec2_client(options)
  Aws::EC2::Client.new(client_options(options))
end
