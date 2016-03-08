require 'twitter'
require 'twitter_oauth'

def client
  return @client if @client

  ck = ENV['TWITTER_CONSUMER_KEY']
  cs = ENV['TWITTER_CONSUMER_SECRET']

  oauth_client = TwitterOAuth::Client.new(
    :consumer_key    => ck,
    :consumer_secret => cs
  )

  at = as = nil
  if !ENV['TWITTER_ACCESS_TOKEN'].empty?
    at = ENV['TWITTER_ACCESS_TOKEN']
    as = ENV['TWITTER_ACCESS_SECRET']
  else
    req_tok = oauth_client.request_token

    puts "Access the url below to authorize this api"
    puts req_tok.authorize_url
    print "[ENTER THE CODE]: "
    code = gets.strip

    access = oauth_client.authorize(
      req_tok.token,
      req_tok.secret,
      :oauth_verifier => code
    )

    puts "TWITTER_ACCESS_TOKEN=#{access.token}"
    puts "TWITTER_ACCESS_SECRET=#{access.secret}"

    at = access.token
    as = access.secret
  end

  @client = Twitter::REST::Client.new do |conf|
    conf.consumer_key        = ck
    conf.consumer_secret     = cs
    conf.access_token        = at
    conf.access_token_secret = as
  end

  @client
end

$client = client
