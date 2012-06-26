package models.products;
import models.Product;

import java.util.*;

public class ProductISBN extends Product {
    static final String REDIS_ISBN_COLLECTION_NAME = "isbn_ranking";

    public ProductISBN(String id, double score, long rank) {
        super(id, score, rank);
    }
    public static List<Product> ranking(int offset, int count) {
        return Product.getRankingList(REDIS_ISBN_COLLECTION_NAME, offset, count);
    }
}


