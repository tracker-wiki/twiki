module Environment
  def boot!
    setup_env
    load_libs!
    configure_gollum
  end

  def configure_gollum
    opts = {
      :default_markup => :markdown,
      :gollum_path    => 'pages.git',
      :wiki_options   => {
        :universal_toc => false
      }
    }

    opts.each { | k , v | Precious::App.set k , v }
  end

  def load_libs
    %w(
      gollum/frontend/app
      rack/cascade
    ).each { | lib | require lib }
  end

  def load_libs!
    begin
      load_libs
    rescue LoadError
      ENV[ 'BUNDLE_GEMFILE' ] ||= File.expand_path 'Gemfile'
      require 'rubygems'
      require 'bundler/setup'

      Bunder.require \
        :default,
        ENV[ 'RACK_ENV' ]

      load_libs or raise LoadError.new( 'Unable to load required libraries!' )
    end
  end

  def setup_env
    env_file = "#{ ROOT }/.env"
    if File.exists?( env_file )
      require 'foreman/env'
      foreman_env = Foreman::Env.new( env_file ).entries do | name , value |
        ENV[ name ] = value unless ENV[ name ]
      end
    end
  end

  extend self
end
