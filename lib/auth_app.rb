class AuthApp < Sinatra::Base
  if ENV[ 'REQUIRES_AUTHENTICATION' ]
    helpers do
      def protected!
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="Restricted Area")

          throw \
            :halt,
            [
              401,
              "Not Authorized!\n"
            ]
        end
      end

      def authorized?
        @auth ||= Rack::Auth::Basic::Request.new request.env

        @auth.provided? && 
          @auth.basic? && 
          @auth.credentials && 
          @auth.credentials == [
                                 ENV[ 'BASIC_AUTH_USERNAME' ],
                                 ENV[ 'BASIC_AUTH_PASSWORD' ]
                               ]
      end
    end

    authenticated_paths = {
      :get  => %w(
                 /create/*
                 /delete/*
                 /edit/*
               ),
      :post => %w(
                 /create
                 /edit/*
                 /preview
                 /revert/:page/*
               )
    }

    authentication_proc = Proc.new do
      protected!
      pass
    end

    authenticated_paths.each do | http_method , paths |
      paths.each do | path |
        send \
          http_method.to_sym,
          path,
          &authentication_proc
      end
    end
  end
end
