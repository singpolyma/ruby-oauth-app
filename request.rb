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

request_token = @consumer.get_request_token
puts request_token.token
puts request_token.secret
