package net.oitobstudio.spokes.rack.ws;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.util.MultiValueMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import net.oitobstudio.spokes.SpokesConfirm;
import net.oitobstudio.spokes.SpokesException;
import net.oitobstudio.spokes.rack.BikeRack;
import net.oitobstudio.spokes.rack.BikeRackCriteria;
import net.oitobstudio.spokes.rack.BikeRackService;
import net.oitobstudio.spokes.rack.BikeRacks;
import net.oitobstudio.spokes.theft.BikeThefts;
import net.oitobstudio.spokes.ws.SpokesBaseController;

@Controller
public class BikeRackController extends SpokesBaseController{
	private static Logger log = Logger.getLogger(BikeRackController.class);
	private BikeRackService bikeRackService;

	@Autowired
	public BikeRackController(BikeRackService bikeRackService) {
		this.bikeRackService = bikeRackService;
	}

	@RequestMapping(value="/racks/{topLeft}_{bottomRight}", method=RequestMethod.GET)
	public ModelAndView getNearestBikeRacks(@PathVariable("topLeft") String topLeft,
			@PathVariable("bottomRight") String bottomRight,
			HttpServletResponse response) {
		BikeRacks nearestRacks = null;
		ModelAndView mav = new ModelAndView("marshaller");
		try{
			BikeRackCriteria criteria = new BikeRackCriteria(topLeft, bottomRight, null);
			nearestRacks = bikeRackService.findNearestBikeRacks(criteria);
			mav.addObject("SpokesResult", nearestRacks);
		}catch(SpokesException e){
			log.error(e);
			mav.addObject("SpokesResult", new BikeRacks(e.getFault()));
			super.addFaultHeader(response);
		}
		return mav;
	}

	@RequestMapping(value="/rack/{bikeRackId}", method=RequestMethod.GET)
	public ModelAndView getBikeRackDetail(@PathVariable("bikeRackId") long bikeRackId) {
		ModelAndView mav = new ModelAndView("marshaller");
		BikeRack bikeRack = bikeRackService.getBikeRackDetail(bikeRackId);
		mav.addObject("SpokesResult", new BikeRacks(bikeRack));
		return mav;
	}

	@RequestMapping(value="/rack", method=RequestMethod.POST)
	public ModelAndView addBikeRack(@RequestBody MultiValueMap<String,Object> addRackParams, 
			HttpServletRequest request,
			HttpServletResponse response) {
		String rackCoordinate = (String)addRackParams.getFirst("rackCoordinate");
		String rackAddress = (String)addRackParams.getFirst("rackAddress");
		ModelAndView mav = new ModelAndView("marshaller");
		try{
			BikeRack newRack = new BikeRack(rackCoordinate, rackAddress);
			bikeRackService.addBikeRack(newRack);
			SpokesConfirm confirm = new SpokesConfirm("The bike rack has been successfully reported.");
			mav.addObject("SpokesResult", confirm);
			response.setStatus(HttpServletResponse.SC_CREATED);
			StringBuffer uri = request.getRequestURL();
			uri.append("/");
			uri.append(newRack.getId());
			response.setHeader("Location", uri.toString());
			//response.setContentLength(mav.getView().toString().getBytes().length);
			response.setContentType("text/xml");
		}catch(SpokesException e){
			log.error(e);
			mav.addObject("SpokesResult", new BikeThefts(e.getFault()));
		}
		return mav;
	}

	@Override
	protected String getDataAccessMsg() {
		return "An error occurred while retrieving the bike rack info.  Please try again.";
	}
}