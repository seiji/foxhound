#!/usr/bin/env ruby
require './config'

def sweep_asin
  Asin.asc(:updated_at).each do |o|
    asin = o.asin
    # before 6 hour
    d = DateTime.now - Rational(6, 24) 
    if d > o.updated_at
      puts "Delete #{asin} : #{o.updated_at}"
      score =REDIS.zrem REDIS_ASIN_COLLECTION_NAME, asin
      o.delete
    else
      return
    end
  end  
end

if $0 == __FILE__
  # write this
  sweep_asin()
end


