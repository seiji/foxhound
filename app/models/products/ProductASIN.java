package models.products;
import models.Product;

import java.util.*;

public class ProductASIN extends Product {
    static final String REDIS_ASIN_COLLECTION_NAME = "asin_ranking";

    public ProductASIN(String id, double score, long rank) {
        super(id, score, rank);
    }
    public static List<Product> ranking(int offset, int count) {
        return Product.getRankingList(REDIS_ASIN_COLLECTION_NAME, offset, count);
    }
}


