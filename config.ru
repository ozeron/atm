$LOAD_PATH.push(File.expand_path('../lib/', __FILE__))
require 'atm/api'
require 'middleware/storage'

use Rack::Reloader
use Middleware::Storage
run Atm::API
