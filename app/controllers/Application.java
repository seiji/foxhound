package controllers;

import play.*;
import play.data.*;
import play.mvc.*;

import views.html.*;
import models.*;
import actions.*;


public class Application extends Controller {

    @Verbose(true)
    public static Result index() {
        return redirect(routes.Application.list());
    }
    public static Result list() {
        return ok(views.html.index.render(Product.ranking(0,100 -1 )) );
    }
    public static Result ranking(int page) {
        return ok(views.html.index.render(Product.ranking(page * 100,
                                                          (page + 1) * 100 - 1 )) );
    }
}
