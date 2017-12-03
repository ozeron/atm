$LOAD_PATH.push(File.expand_path('../lib/', __FILE__))
require 'api/root'
require 'middleware/storage'
require 'rack-health'

use Rack::Reloader
use Rack::Health, path: '/healthz'
use Middleware::Storage
run API::Root
