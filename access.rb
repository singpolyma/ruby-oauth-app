#!/usr/bin/ruby

require 'rubygems'
require  'oauth/consumer'

@consumer = OAuth::Consumer.new('key123', 'sekret', {
	:site => 'http://csclub.uwaterloo.ca:4567',
	:scheme => :header,
	:http_method => :get,
	:request_token_path => '/oauth/request_token',
	:access_token_path => '/oauth/access_token',
	:authorize_url => '/oauth/authorize'
})

request_token = OAuth::RequestToken.new(@consumer, ARGV[0], ARGV[1])
access_token = request_token.get_access_token
	
puts access_token.token
puts access_token.secret
