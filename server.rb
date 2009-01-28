begin; require 'rubygems'; rescue LoadError; end

require 'sinatra'
require 'oauth/request_proxy/rack_request'
require File.dirname(__FILE__) + '/../oauth_provider/lib/oauth_provider'

provider = OAuthProvider::create(:sqlite3, 'store.sqlite3')
begin
	provider.add_consumer('http://google.com', OAuthProvider::Token.new('key123', 'sekret'))
rescue Exception
end

error do
  exception = request.env['sinatra.error']
  warn "%s: %s" % [exception.class, exception.message]
  warn exception.backtrace.join("\n")
  "Sorry there was a nasty error"
end

# OAuth routes
post "/oauth/request_token" do
  provider.issue_request(request).query_string
end
get "/oauth/request_token" do
  provider.issue_request(request).query_string
end

post "/oauth/access_token" do
  if access_token = provider.upgrade_request(request)
    access_token.query_string
  else
    raise Sinatra::NotFound, "No such request token"
  end
end
get "/oauth/access_token" do
  if access_token = provider.upgrade_request(request)
    access_token.query_string
  else
    raise Sinatra::NotFound, "No such request token"
  end
end

# Authorize endpoints
get "/oauth/authorize" do
  if @request_token = provider.backend.find_user_request(params[:oauth_token])
    erb :authorize
  else
    raise Sinatra::NotFound, "No such request token"
  end
end

post "/oauth/authorize" do
  if request_token = provider.backend.find_user_request(params[:oauth_token])
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
  access_token = provider.verify_access(request)
  "CAN HAS STOVE FOR #{access_token.consumer.name}"
end

use_in_file_templates!

__END__

@@ authorize
<h2>You are about to authorize (<%= @request_token.consumer.callback %>)</h2>
<form action="/oauth/authorize" method="post">
  <p>
    <input id="oauth_token" name="oauth_token" type="hidden" value="<%= @request_token.shared_key %>" />
  </p>

  <p>
    <input name="commit" type="submit" value="Activate" />
  </p>
</form>
