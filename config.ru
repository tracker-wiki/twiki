$stdout.sync = true
ROOT         = File.dirname File.expand_path( __FILE__ )

require "#{ ROOT }/lib/environment"
Environment.boot!

require "#{ ROOT }/lib/auth_app"
run Rack::Cascade.new [
                        AuthApp,
                        Precious::App
                      ]
