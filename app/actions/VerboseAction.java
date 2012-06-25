package actions;

import play.*;
import play.mvc.*;

public class VerboseAction extends Action<Verbose> {
    public Result call(Http.Context ctx) throws Throwable {
        if(configuration.value()) {
            Logger.info("action kita! " + ctx);
        } else {
            Logger.info("no action ");
        }
        return delegate.call(ctx);
    }
}
