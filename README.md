# SteamDonkey

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/steam_donkey`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'steam_donkey'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install steam_donkey

## Usage

```
$ donkey help
Commands:
  donkey cf              # Manage Cloudformation stacks
  donkey ec2             # Manage EC2 instances
  donkey help [COMMAND]  # Describe available commands or one specific command
  donkey sg              # Manage Security Groups
  donkey vpc             # Manage VPCs
```

### Selecting Resource Columns

You can select any resources column in either CamelCase or underscore.

```
$ donkey ec2 ls --columns Id,Name,launch_time
Id                    Name                    State
i-0721bb9f71f8a6045   dev-cass-test-datanode  running
i-029a8574fb8233c1b   rhill-ftp-chef-node     running
...
```

### Filtering Resources

#### --filters 'Name=my-instance'

Literal filters

```
$ donkey ec2 ls --filters Name=my-instance
Id                    Name         State
i-0721bb9f71f8a6045   my-instance  running
```

#### --filters 'Name=?/^dev-/'

Regex filters

```
$ donkey ec2 ls --filters 'Name=?/^dev-/'
Id                    Name                     State
i-0721bb9f71f8a6045   dev-cass-test-datanode   running
i-029a8574fb8233c1b   dev-rhill-ftp-chef-node  running
...
```

#### --filters 'Name=!/^dev-/'

Negative regex

```
$ donkey ec2 ls --filters 'Name=!/^dev-/'
Id                    Name                      State
i-0721bb9f71f8a6045   qa-cass-test-datanode     running
i-029a8574fb8233c1b   prod-rhill-ftp-chef-node  running
...
```

### Sorting

#### --sort 'Name,Id'

```
$ donkey ec2 ls --sort 'LaunchTime,Name'
Id                    Name                      State
i-0721bb9f71f8a6045   qa-cass-test-datanode     running
i-029a8574fb8233c1b   prod-rhill-ftp-chef-node  running
...
```

#### --sort 'Name=desc,Id=asc'

```
$ donkey ec2 ls --sort 'LaunchTime,Name=desc,Id=asc'
Id                    Name                      State
i-0721bb9f71f8a6045   qa-cass-test-datanode     running
i-029a8574fb8233c1b   prod-rhill-ftp-chef-node  running
...
```

### Output Options

#### --format pretty

```
$ donkey ec2 ls --format pretty
Id                    Name                    State
i-0721bb9f71f8a6045   dev-cass-test-datanode  running
i-029a8574fb8233c1b   rhill-ftp-chef-node     running
```

#### --format raw

```
$ donkey ec2 ls --format pretty
Id,Name,State
i-0721bb9f71f8a6045,dev-cass-test-datanode,running
i-029a8574fb8233c1b,rhill-ftp-chef-node,running
```

### Raw 

#### --raw

```
$ donkey ec2 ls --raw
i-0721bb9f71f8a6045,dev-cass-test-datanode,running
i-029a8574fb8233c1b,rhill-ftp-chef-node,running
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/petercoulton/steam_donkey.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


