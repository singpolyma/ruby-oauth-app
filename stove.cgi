#!/usr/bin/ruby

begin

	require 'cgi'
	require 'oauth_provider/cgi_request_proxy'
	require 'oauth_provider'

	cgi = CGI.new
	provider = OAuthProvider::create(:mysql, hostname, username, password, dbname)

rescue Exception
	cgi.out({'status' => 'FORBIDDEN', 'type' => 'text/plain'}) {
		$!.inspect
	}
	exit
end

begin
	access_token = provider.confirm_access(cgi)
rescue Exception
	cgi.out({'status' => 'FORBIDDEN', 'type' => 'text/plain'}) {
		$!.inspect
	}
	exit
end

cgi.out('text/plain') {
	begin
		"STOVE FOR #{access_token.inspect}"
	rescue
		$!.inspect
	end
}

