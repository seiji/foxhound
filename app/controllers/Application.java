package controllers;

import play.*;
import play.data.*;
import play.mvc.*;

import views.html.*;
import models.*;
import models.products.*;

import actions.*;

public class Application extends Controller {

    @Verbose(true)
    public static Result index() {
        return redirect(routes.Application.ranking("isbn", 0));
    }
    public static Result rankingIndex() {
        return redirect(routes.Application.ranking("isbn", 0));
    }

    @Verbose(true)
    public static Result ranking(String rankingType, int page) {
        if (rankingType.equals("asin")) {
            return ok(views.html.index.render(rankingType, ProductASIN.ranking(page * 100,
                                                                  (page + 1) * 100 - 1 )) );
        } else if (rankingType.equals("isbn")) {
            return ok(views.html.index.render(rankingType, ProductISBN.ranking(page * 100,
                                                                  (page + 1) * 100 - 1 )) );
        } else {
            return notFound();
        }
    }
}
