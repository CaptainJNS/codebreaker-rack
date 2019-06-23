require_relative 'dependency'

use Rack::Reloader, 0
use Rack::Session::Cookie, key: 'rack.session', secret: '123456'

run Rack::Cascade.new([Rack::File.new('templates'), CBGame])
