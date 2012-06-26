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
        return redirect(routes.Application.ranking("isbn", 1));
    }
    public static Result rankingIndex() {
        return redirect(routes.Application.ranking("isbn", 1));
    }

    @Verbose(true)
    public static Result ranking(String rankingType, int page) {
        if (rankingType.equals("asin")) {
            return ok(views.html.index.render( rankingType,
                                               page,
                                               ProductASIN.ranking((page -1) * 100, page * 100 - 1 )
                                              )
                      );
        } else if (rankingType.equals("isbn")) {
            return ok(views.html.index.render( rankingType,
                                               page,
                                               ProductISBN.ranking( (page-1) * 100, page * 100 - 1 )
                                             )
                      );
        } else {
            return notFound();
        }
    }
}
