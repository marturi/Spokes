package net.oitobstudio.spokesdc.smartbike.ws;

import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import net.oitobstudio.spokes.SpokesException;
import net.oitobstudio.spokesdc.smartbike.SmartBikeStation;
import net.oitobstudio.spokesdc.smartbike.SmartBikeStationCriteria;
import net.oitobstudio.spokesdc.smartbike.SmartBikeStationService;
import net.oitobstudio.spokesdc.smartbike.SmartBikeStations;
import net.oitobstudio.spokes.ws.SpokesBaseController;

@Controller
public class SmartBikeStationController extends SpokesBaseController{
	private static Logger log = Logger.getLogger(SmartBikeStationController.class);
	private SmartBikeStationService smartBikeStationService;

	@Autowired
	public SmartBikeStationController(SmartBikeStationService smartBikeStationService) {
		this.smartBikeStationService = smartBikeStationService;
	}

	@RequestMapping(value="/smartbikestations/{topLeft}_{bottomRight}", method=RequestMethod.GET)
	public ModelAndView getNearestSmartBikeStations(@PathVariable("topLeft") String topLeft,
			@PathVariable("bottomRight") String bottomRight,
			HttpServletResponse response) {
		SmartBikeStations nearestSmartBikeStations = null;
		ModelAndView mav = new ModelAndView("marshaller");
		try{
			SmartBikeStationCriteria criteria = new SmartBikeStationCriteria(topLeft, bottomRight, null);
			nearestSmartBikeStations = smartBikeStationService.findNearestSmartBikeStations(criteria);
			mav.addObject("SpokesResult", nearestSmartBikeStations);
		}catch(SpokesException e){
			log.error(e);
			mav.addObject("SpokesResult", new SmartBikeStations(e.getFault()));
			super.addFaultHeader(response);
		}
		return mav;
	}

	@RequestMapping(value="/smartbikestation/{stationId}", method=RequestMethod.GET)
	public ModelAndView getSmartBikeStationDetail(@PathVariable("stationId") long stationId) {
		ModelAndView mav = new ModelAndView("marshaller");
		SmartBikeStation smartBikeStation = smartBikeStationService.getSmartBikeStationDetail(stationId);
		mav.addObject("SpokesResult", new SmartBikeStations(smartBikeStation));
		return mav;
	}

	@Override
	protected String getDataAccessMsg() {
		return "An error occurred while retrieving the smart bike station info.  Please try again.";
	}
}