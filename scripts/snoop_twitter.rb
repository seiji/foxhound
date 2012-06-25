#!/usr/bin/env ruby
require 'pp'
require 'net/http'
require 'uri'

require 'pit'
require 'tweetstream'
require 'mongoid'
require 'redis'

### MongoDB
# db.createCollection("capped", {capped: true, size:1000, max: 5})
class Tweet                    
  include Mongoid::Document
  self.collection_name = 'tweets'
  field :id,          :type => Float
  field :text,        :type => String
  field :screen_name, :type => String
  field :user_id, :type => Float
  field :created_at,  :type => DateTime
end

# db.tweet_urls.createIndex({url: 1}, {unique: true})

# db.tweet_urls.ensureIndex({url: 1}, {unique: true});
class TweetURL
  include Mongoid::Document
  self.collection_name = 'tweet_urls'
  field :url, :type => String
  field :updated_at,  :type => DateTime
end

### Redis
# collection url_ranking

###  configuure
REDIS= Redis.new(:hoest =>'localhost', :port => 6379)
REDIS_URL_COLLECTION_NAME= "url_ranking"

Mongoid.configure do |conf|
  conf.master = Mongo::Connection.new('localhost', 27017).db('foxhound')
end
twitter_config = Pit.get('twitter.com')

TweetStream.configure do |config|
  config.username = twitter_config["user"]
  config.password = twitter_config["pass"]
  config.auth_method = :basic
  config.parser   = :yajl
end
###

# write this
#TweetStream::Client.new.sample do |status|
#    && status.user.followers_count >= 100 \
URI_RE = URI.regexp(['http'])

EM.run do
  client = TweetStream::Client.new
  def save_tweet(status)
    EM.defer do
      if status.user.lang == 'ja' \
        && status.in_reply_to_user_id == nil \
        && status.text.include?('http:')
        puts "#{status.user.screen_name} (#{status.user.followers_count}): #{status.text}"
        
        text= status.text
        text.scan(URI_RE)
        url= $&
        puts url
        uri=URI.parse(url)
        if (url =~ /t\.co/)
          Net::HTTP.start(uri.host, uri.port){|http|
            response = http.get(uri.path)
            url = response['location']
          }
          unless url
            next
          end
          uri = URI.parse(url)
        end
        search_uri= "#{uri.scheme}://#{uri.host}#{uri.path}"
        product_id = nil
        if search_uri =~ /\/(B0[^\/]+)/
          product_id = $1
        else
          next
        end
        puts product_id
        created_at = status.created_at

        # query
        REDIS.zincrby REDIS_URL_COLLECTION_NAME, 1, product_id

        tweet = Tweet.new(
                          :id   => status.id,
                          :text => text,
                          :screen_name => status.user.screen_name,
                          :user_id => status.user.id,
                          :created_at => created_at
                          )
        tweet.save
      end
    end
  end
  client.track('amazon') do |status|
    save_tweet(status)
  end
end


