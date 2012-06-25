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
class Asin
  include Mongoid::Document
  self.collection_name = 'asin'
  field :asin,        :type => String
  field :updated_at,  :type => DateTime
  index :asin, :unique => true
end
class Isbn
  include Mongoid::Document
  self.collection_name = 'isbn'
  field :isbn,        :type => String
  field :updated_at,  :type => DateTime
  index :isbn, :unique => true
end

### Redis
# collection url_ranking

###  configuure
REDIS= Redis.new(:hoest =>'localhost', :port => 6379)
REDIS_URL_COLLECTION_NAME= "url_ranking" # asin
REDIS_ISBN_COLLECTION_NAME= "isbn_ranking"


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
        next if url == "http://"
        while (url =~ /t\.co/ \
               or url =~ /amzn\.to/ \
               or url =~ /dlvr\.it/ \
               or url =~ /tinyurl\.com/)
          begin
            uri = URI.parse(url)
          rescue URI::InvalidURIError
            next
          end
          Net::HTTP.start(uri.host, uri.port){|http|
            response = http.get(uri.path)
            url = response['location']
          }
          next unless url
        end

        unless url =~ /amazon/
          puts "[[What url]] :: #{url}"
          next
        end

        begin
          uri = URI.parse(url)
        rescue URI::InvalidURIError
          next
        end
        search_uri= "#{uri.scheme}://#{uri.host}#{uri.path}"
        asin = nil
        if search_uri =~ /\/([B0-9][A-Z0-9]{9})/
          asin = $1
        else
          puts "Error #{search_uri}"
          next
        end
        next unless asin

        created_at = status.created_at

        # query
        puts "[REGIST] #{asin}"
        if asin =~ /^B/
          REDIS.zincrby REDIS_URL_COLLECTION_NAME, 1, asin
          Asin.new(
                   :asin => asin,
                   :updated_at => created_at
                   ).upsert
        else
          REDIS.zincrby REDIS_ISBN_COLLECTION_NAME, 1, asin          
          Isbn.new(
                   :isbn => asin,
                   :updated_at => created_at
                   ).upsert
        end
        Tweet.new(
                  :id   => status.id,
                  :text => text,
                  :screen_name => status.user.screen_name,
                  :user_id => status.user.id,
                  :created_at => created_at
                  ).save
      end
    end
  end
  client.track('amazon') do |status|
    save_tweet(status)
  end
end


