package net.oitobstudio.spokes.ws;

import java.io.PrintWriter;
import java.io.StringWriter;

import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import org.springframework.dao.DataAccessException;
import org.springframework.core.NestedRuntimeException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.ModelAndView;

import net.oitobstudio.spokes.SpokesFault;

public abstract class SpokesBaseController {
	private static Logger log = Logger.getLogger(SpokesBaseController.class);

    @ExceptionHandler(DataAccessException.class)
    public ModelAndView handleException(DataAccessException ex) {
    	ModelAndView mav = new ModelAndView("marshaller");
    	SpokesFault fault = new SpokesFault(getDataAccessMsg());
    	mav.addObject("SpokesResult", fault);
    	log.error(ex);
        return mav;
    }

    @ExceptionHandler(Exception.class)
    public ModelAndView handleException(Exception ex) {
    	ModelAndView mav = new ModelAndView("marshaller");
    	SpokesFault fault = new SpokesFault("An unexpected error occured.  Please try again.");
    	mav.addObject("SpokesResult", fault);
    	log.error(ex);
    	if(ex instanceof NestedRuntimeException){
    		StringWriter exceptionMsg = new StringWriter();
    		PrintWriter printWriter = new PrintWriter(exceptionMsg);
    		((NestedRuntimeException)ex).getRootCause().printStackTrace(printWriter);
    		log.error(exceptionMsg.toString());
    	}
        return mav;
    }

    protected void addFaultHeader(HttpServletResponse response) {
    	response.addHeader("X-Spokes-Fault", "TRUE");
    }

    protected abstract String getDataAccessMsg();
}