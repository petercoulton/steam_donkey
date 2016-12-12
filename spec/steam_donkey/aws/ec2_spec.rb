require 'spec_helper'
require 'steam_donkey/aws/ec2'

describe SteamDonkey::AWS::EC2::Listing do

  before(:each) do
    @listing = SteamDonkey::AWS::EC2::Listing.new
  end

  it 'should return empty has for no parameters' do
    expect(@listing.parse_filters).to eq([])
  end

  it 'should return simple parameters unchanged' do
    expect(@listing.parse_filters 'a,b,c').to eq([
                                                     { :name => 'a', :test =>nil},
                                                     { :name => 'b', :test =>nil},
                                                     { :name => 'c', :test =>nil}
                                                 ])
  end

  it 'should return literal parameters unchanged' do
    expect(@listing.parse_filters 'a=1,b=2,c=3').to eq([
                                                           { :name => 'a', :test =>'1'},
                                                           { :name => 'b', :test =>'2'},
                                                           { :name => 'c', :test =>'3'}
                                                       ])
  end

  it 'should return regex parameters as regex' do
    expect(@listing.parse_filters 'a=?/1/,b=?/2/,c=?/3/').to eq([
                                                                    { :name => 'a', :test => '?/1/'},
                                                                    { :name => 'b', :test => '?/2/'},
                                                                    { :name => 'c', :test => '?/3/'}
                                                                ])
  end

  it 'should return aliased parameters with substitutes' do
    aliases = [
        { :test => /a/, :value => 'aa' },
        { :test => /b/, :value => 'bb' },
        { :test => /c/, :value => 'cc' }
    ]
    expect(@listing.parse_filters('a=?/1/,b=?/2/,c=?/3/', aliases)).to eq([
                                                                    { :name => 'aa', :test => '?/1/'},
                                                                    { :name => 'bb', :test => '?/2/'},
                                                                    { :name => 'cc', :test => '?/3/'}
                                                                ])
  end




end