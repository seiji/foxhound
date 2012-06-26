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
# db.asin.createIndex({url: 1}, {unique: true})
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
Mongoid.configure do |conf|
  conf.master = Mongo::Connection.new('localhost', 27017).db('foxhound')
end

### Redis
# collection url_ranking
REDIS_ASIN_COLLECTION_NAME = "asin_ranking" # asin
REDIS_ISBN_COLLECTION_NAME= "isbn_ranking"

REDIS= Redis.new(:hoest =>'localhost', :port => 6379)

TWITTER_CONFIG = Pit.get('twitter.com')
###
