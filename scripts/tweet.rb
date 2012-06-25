#!/usr/bin/env ruby
require 'mongoid'
require 'pp'
require 'eventmachine'

class Tweet
  include Mongoid::Document
  self.collection_name = 'tweets'
  field :id_str,      :type => Float
  field :text,        :type => String
  field :screen_name, :type => String
  field :user_id_str, :type => String
  field :created_at,  :type => DateTime
end

Mongoid.configure do |conf|
  conf.master = Mongo::Connection.new('localhost', 27017).db('foxhound')
end

if $0 == __FILE__
  # write this
  
  Tweet.desc(:_id).limit(3).each do |tweet|
    pp tweet
  end
  # Tweet.create!(
  #               id_str: "aid",
  #               text: "text",
  #               screen_name: "screen",
  #               user_id_str: "user_id_str",
  #               created_at: "Thu Jun 17 13:47:06 +0000 2010"
  #               )
  
end
