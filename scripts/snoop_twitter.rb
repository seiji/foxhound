#!/usr/bin/env ruby
require 'pp'
require 'net/http'
require 'uri'

require './config'

TweetStream.configure do |config|
  config.username    = TWITTER_CONFIG["user"]
  config.password    = TWITTER_CONFIG["pass"]
  config.auth_method = :basic
  config.parser      = :yajl
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
            Net::HTTP.start(uri.host, uri.port){|http|
              response = http.get(uri.path)
              url = response['location']
            }
          rescue
            next
          end
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
          REDIS.zincrby REDIS_ASIN_COLLECTION_NAME, 1, asin
          Asin.new(
                   :asin => asin,
                   :updated_at => created_at
                   ).upsert
          product_id= asin
        else
          REDIS.zincrby REDIS_ISBN_COLLECTION_NAME, 1, asin          
          Isbn.new(
                   :isbn => asin,
                   :updated_at => created_at
                   ).upsert
        end
        Tweet.new(
                  :id          => status.id,
                  :text        => text,
                  :screen_name => status.user.screen_name,
                  :user_id     => status.user.id,
                  :product_id  => asin,
                  :created_at  => created_at
                  ).save
      end
    end
  end
  client.track('amazon') do |status|
    save_tweet(status)
  end
end


