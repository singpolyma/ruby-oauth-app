#!/usr/bin/ruby

require 'rubygems'
require  'oauth/consumer'

@consumer = OAuth::Consumer.new( 'key123', 'sekret', {
	:site => 'http://csclub.uwaterloo.ca/~s3weber',
	:scheme => :query_string,
	:http_method => :get,
	:request_token_path => '',
	:access_token_path => '',
	:authorize_url => ''
})

request_token = OAuth::RequestToken.new(@consumer, ARGV[0], ARGV[1])
a = @consumer.create_signed_request(:get, 'http://csclub.uwaterloo.ca/~s3weber/apt/control.cgi', request_token)

puts a.path
