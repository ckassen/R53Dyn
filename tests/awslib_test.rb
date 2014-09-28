require 'minitest/spec'
require 'minitest/autorun'

require 'r53dyn/aws'

describe 'Aws' do

  before :each do
    option = {:access_key_id => ENV['AWS_KEY'],
    :secret_access_key => ENV['AWS_SECRET']}

    @aws = R53Dyn::Aws.new(option)
  end

  it 'should get the zoneid' do
    z = @aws.get_zoneid('domain.')
    true.must_be == false
  end
end