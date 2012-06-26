package models;
import java.util.*;

import play.*;
import play.data.*;
import play.mvc.*;

import com.typesafe.plugin.RedisPlugin;
import redis.clients.jedis.*;

public class Product {
    public String id;
    public int score;
    public long rank;
    
    public Product(String id, double score, long rank) {
        this.id = id;
        this.score = (int)score;
        this.rank = rank;
    }
    
    protected static List<Product> getRankingList(String collectionName, int offset, int count) {
        List<Product> productList = new ArrayList<Product>();

        JedisPool p = Play.application().plugin(RedisPlugin.class).jedisPool();
        Jedis jedis = p.getResource();

        for ( Iterator<Tuple> memberItr = jedis.zrevrangeWithScores(collectionName, offset, count).iterator();memberItr.hasNext(); ) {
            final Tuple memSet  =  memberItr.next();
            final String productID = memSet.getElement();
            double score = memSet.getScore();
            final long rank = jedis.zcount(collectionName, score + 1.0d, Double.POSITIVE_INFINITY)  + 1;
            Product product = new Product(productID, score, rank);
            productList.add(product);
        }
        p.returnResource(jedis);
        return productList;
    }        

}


