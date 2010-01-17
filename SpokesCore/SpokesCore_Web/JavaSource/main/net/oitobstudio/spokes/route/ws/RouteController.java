package net.oitobstudio.spokes.route.ws;

import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import net.oitobstudio.spokes.SpokesException;
import net.oitobstudio.spokes.route.Route;
import net.oitobstudio.spokes.route.RouteCriteria;
import net.oitobstudio.spokes.route.RouteService;
import net.oitobstudio.spokes.ws.SpokesBaseController;

@Controller
public class RouteController extends SpokesBaseController{
	private static Logger log = Logger.getLogger(RouteController.class);
	private RouteService routeService;

	@Autowired
	public RouteController(RouteService routeService) {
		this.routeService = routeService;
	}

	@RequestMapping(value="/route/{startPt}_{endPt}", method=RequestMethod.GET)
	public ModelAndView getRoute(@PathVariable("startPt") String startPt, 
			@PathVariable("endPt") String endPt,
			HttpServletResponse response) {
		RouteCriteria rc = new RouteCriteria(startPt, endPt, null);
		Route route = null;
		ModelAndView mav = new ModelAndView("marshaller");
		try{
			route = routeService.getShortestPathRoute(rc);
			mav.addObject("SpokesResult", route);
		}catch(SpokesException e){
			log.error(e);
			mav.addObject("SpokesResult", new Route(e.getFault()));
			response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
			super.addFaultHeader(response);
		}
		return mav;
	}

	@Override
	protected String getDataAccessMsg() {
		return "An error occurred while creating your route.  Please try again.";
	}
}