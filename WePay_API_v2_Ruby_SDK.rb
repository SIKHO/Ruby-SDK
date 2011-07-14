require 'rubygems'
require 'uri'
require 'json'
require 'net/http'
require 'net/https'
require 'cgi'

=begin
helps you make API calls to the WePay API v2
=end

class WePay
		
	# initializes the API application, api_endpoint should be something like 'https://stage.wepay.com/v2'
	def initialize(_client_id, _client_secret, _api_endpoint = 'https://stage.wepay.com/v2', _use_ssl = true)
		@client_id = _client_id
		@client_secret = _client_secret
		@api_endpoint = _api_endpoint
		@use_ssl = _use_ssl
	end
	
	# make a call to the WePay API
	def call(call, access_token = false, params = false)
		# get the url
		url = URI.parse(@api_endpoint + call)
		# construct the call data and access token
		call = Net::HTTP::Post.new(url.path, initheader = {'Content-Type' =>'application/json'})
		if params
			call.body = params.to_json
		end
		if access_token
			call.add_field('Authorization: Bearer', access_token);
		end
		# create the request object
		request = Net::HTTP.new(url.host, url.port)
		request.use_ssl = @use_ssl
		# make the call
		response = request.start {|http| http.request(call) }
		# returns JSON response as ruby hash
		JSON.parse(response.body)
	end
	
	# this function returns the URL that you send the user to to authorize your API application
	# the redirect_uri must be a full uri (ex https://www.wepay.com)
	def oauth2_authorize_url(redirect_uri, user_email = false, user_name = false)
		url = @api_endpoint + '/oauth2/authorize?client_id=' + @client_id + '&redirect_uri=' + redirect_uri + '&scope=manage_accounts,view_balance,collect_payments,refund_payments,view_user' #scope is hard coded for now
		url += user_name ? '&user_name=' + CGI::escape(user_name) : ''
		url += user_email ? '&user_email=' + CGI::escape(user_email) : ''
	end
	
	#this function will make a call to the /v2/oauth2/token endpoint to exchange a code for an access_token
	def oauth2_token(code, redirect_uri)
		call('/oauth2/token', false, {'client_id' => @client_id, 'client_secret' => @client_secret, 'redirect_uri' => redirect_uri, 'code' => code })
	end
	
end
