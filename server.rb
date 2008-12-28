require 'rubygems'

require 'sinatra'
require File.dirname(__FILE__) + '/vendor/oauth/lib/oauth'
require File.dirname(__FILE__) + '/vendor/oauth_provider/lib/oauth_provider'

require 'oauth_provider/stores/sqlite3'
store = OAuthProvider::Stores::Sqlite3Store.new('sinatra-oauth.sqlite3')
provider = OAuthProvider::Provider.new(store)

error do
  exception = request.env['sinatra.error']
  warn "%s: %s" % [exception.class, exception.message]
  warn exception.backtrace.join("\n")
  "Sorry there was a nasty error"
end

# Dummy for creating a dummy consumer
delete "/db" do
  warn "Automigrating!"
  unless provider.consumer_for('key123')
    provider.add_consumer('Awesome app', 'key123', 'sekret', 'http://localhost:4568/callback')
  end
  "OK"
end

# OAuth routes
post "/oauth/request_token" do
  provider.generate_request_token(request).query_string
end

post "/oauth/access_token" do
  if access_token = provider.generate_access_token(request)
    access_token.query_string
  else
    raise Sinatra::NotFound, "No such request token"
  end
end

# Authorize endpoints
get "/oauth/authorize" do
  if @request_token = provider.request_token_for(params[:oauth_token])
    erb :authorize
  else
    raise Sinatra::NotFound, "No such request token"
  end
end

post "/oauth/authorize" do
  if request_token = provider.request_token_for(params[:oauth_token])
    if request_token.authorize
      redirect request_token.callback
    else
      raise "Could not authorize"
    end
  else
    raise Sinatra::NotFound, "No such request token"
  end
end

# Example protected resource
get "/stove" do
  access_token = provider.check_access(request)
  "CAN HAS STOVE FOR #{access_token.consumer.name}"
end

use_in_file_templates!

__END__

@@ authorize
<h2>You are about to authorize <%= @request_token.consumer.name %> (<%= @request_token.consumer.callback %>)</h2>
<form action="/oauth/authorize" method="post">
  <p>
    <input id="oauth_token" name="oauth_token" type="hidden" value="<%= @request_token.shared %>" />
  </p>

  <p>
    <input name="commit" type="submit" value="Activate" />
  </p>
</form>
