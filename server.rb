require 'rubygems'
require 'sinatra'
require 'json'
require "active_support/core_ext/numeric/time"

get '/' do
  @bucket = "YOUR BUCKET"
  @aws_access_key = "YOUR AWS ACCESS KEY"
  @aws_secret_key = "YOUT AWS SECRET KEY"

  @confirmation_page = "#{request.url}confirmation"

  policy_credentials = {
    :expiration => (Time.now + 30.minute).utc.iso8601,
    :conditions => [
      {:bucket => @bucket},
      ["starts-with", "$key", "uploads/"],
      {:acl => "private"},
      {:success_action_redirect => @confirmation_page}
    ]
  }.to_json

  @policy = policy(policy_credentials)
  @signature = signature(@policy, @aws_secret_key)

  erb :index
end

get "/confirmation" do
  erb :confirmation
end


private

def policy(policy_credentials)
  Base64.encode64(policy_credentials).gsub("\n","")
end

def signature(policy, aws_secret_key)
  Base64.encode64(
    OpenSSL::HMAC.digest(
      OpenSSL::Digest::Digest.new('sha1'),
      aws_secret_key, 
      policy
    )
  ).gsub("\n","")
end