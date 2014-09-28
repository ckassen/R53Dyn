require 'rubygems'
require 'bundler'

Bundler.require
$: << File.expand_path('../', __FILE__)
$: << File.expand_path('../lib', __FILE__)

require 'dotenv'
Dotenv.load

require 'app/routes'

module R53Dyn
  class App < Sinatra::Application
    configure do
      disable :method_override
      disable :static
    end

    use Rack::Deflater
    use R53Dyn::Routes::Update
  end
end
