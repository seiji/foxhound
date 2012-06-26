package models;
import java.util.*;

import play.*;
import play.data.*;
import play.mvc.*;

import com.typesafe.plugin.RedisPlugin;
import redis.clients.jedis.*;

public class Product {
    static final String REDIS_ASIN_COLLECTION_NAME = "asin_ranking";

    public String id;
    public double score;
    public long rank;
    
    public Product(String id, double score, long rank) {
        this.id = id;
        this.score = score;
        this.rank = rank;
    }

    public static List<Product> ranking(int offset, int count) {
        List<Product> productList = new ArrayList<Product>();

        JedisPool p = Play.application().plugin(RedisPlugin.class).jedisPool();
        Jedis jedis = p.getResource();

        for ( Iterator<Tuple> memberItr = jedis.zrevrangeWithScores(REDIS_ASIN_COLLECTION_NAME, offset, count).iterator();memberItr.hasNext(); ) {
            final Tuple memSet  =  memberItr.next();
            final String productID = memSet.getElement();
            double score = memSet.getScore();
            final long rank = jedis.zcount(REDIS_ASIN_COLLECTION_NAME, score + 1.0d, Double.POSITIVE_INFINITY)  + 1;
            Product product = new Product(productID, score, rank);
            productList.add(product);
        }
        p.returnResource(jedis);
        return productList;
    }        

}


