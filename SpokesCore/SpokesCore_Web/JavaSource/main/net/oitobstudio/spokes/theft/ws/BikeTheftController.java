package net.oitobstudio.spokes.theft.ws;

import java.util.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;

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
import net.oitobstudio.spokes.MissingInputException;
import net.oitobstudio.spokes.theft.BikeTheft;
import net.oitobstudio.spokes.theft.BikeTheftCriteria;
import net.oitobstudio.spokes.theft.BikeTheftService;
import net.oitobstudio.spokes.theft.BikeThefts;
import net.oitobstudio.spokes.ws.SpokesBaseController;

@Controller
public class BikeTheftController extends SpokesBaseController{
	private static Logger log = Logger.getLogger(BikeTheftController.class);
	private BikeTheftService bikeTheftService;
	private String dataAccessErrorMsg = "An error occurred while retrieving the bike theft info.  Please try again.";

	@Autowired
	public BikeTheftController(BikeTheftService bikeTheftService) {
		this.bikeTheftService = bikeTheftService;
	}

	@RequestMapping(value="/thefts/{topLeft}_{bottomRight}", method=RequestMethod.GET)
	public ModelAndView getNearbyBikeThefts(@PathVariable("topLeft") String topLeft,
			@PathVariable("bottomRight") String bottomRight,
			HttpServletResponse response) {
		BikeThefts nearbyThefts = null;
		ModelAndView mav = new ModelAndView("marshaller");
		try{
			BikeTheftCriteria criteria = new BikeTheftCriteria(topLeft, bottomRight, null);
			nearbyThefts = bikeTheftService.getNearbyBikeThefts(criteria);
			mav.addObject("SpokesResult", nearbyThefts);
		}catch(SpokesException e){
			log.error(e);
			mav.addObject("SpokesResult", new BikeThefts(e.getFault()));
		}
		return mav;
	}

	@RequestMapping(value="/theft/{bikeTheftId}", method=RequestMethod.GET)
	public ModelAndView getBikeTheftDetail(@PathVariable("bikeTheftId") long bikeTheftId) {
		ModelAndView mav = new ModelAndView("marshaller");
		BikeTheft theft = bikeTheftService.getBikeTheftDetail(bikeTheftId);
		mav.addObject("SpokesResult", new BikeThefts(theft));
		return mav;
	}

	@RequestMapping(value="/theft", method=RequestMethod.POST)
	public ModelAndView reportBikeTheft(@RequestBody MultiValueMap<String,Object> theftParams, 
			HttpServletRequest request,
			HttpServletResponse response) {
		dataAccessErrorMsg = "An error occurred while reporting the bike theft.  Please try again.";
		String theftCoordinate = (String)theftParams.getFirst("theftCoordinate");
		String comments = (String)theftParams.getFirst("comments");
		String theftDateStr = (String)theftParams.getFirst("theftDate");
		String rackIdStr = (String)theftParams.getFirst("bikeRackId");
		Long rackId = null;
		if(rackIdStr != null && rackIdStr.length() > 0) {
			rackId = new Long(rackIdStr.trim());
		}
		ModelAndView mav = new ModelAndView("marshaller");
		try{
			BikeTheft reportedTheft = new BikeTheft(rackId, theftCoordinate, comments, parseTheftDate(theftDateStr));
			bikeTheftService.reportBikeTheft(reportedTheft);
			SpokesConfirm confirm = new SpokesConfirm("The theft of your bike has been successfully reported.");
			mav.addObject("SpokesResult", confirm);
			response.setStatus(HttpServletResponse.SC_CREATED);
			StringBuffer uri = request.getRequestURL();
			uri.append("/");
			uri.append(reportedTheft.getId());
			response.setHeader("Location", uri.toString());
			//response.setContentLength(mav.getView().toString().getBytes().length);
			response.setContentType("text/xml");
		}catch(SpokesException e){
			log.error(e);
			mav.addObject("SpokesResult", new BikeThefts(e.getFault()));
		}
		return mav;
	}

	private Date parseTheftDate(String theftDateStr) throws SpokesException{
		SimpleDateFormat sdf = new SimpleDateFormat("MM-dd-yyyy");
		Date theftDate = null;
		try{
			theftDate = sdf.parse(theftDateStr);
		}catch(ParseException pe){
			log.error(pe);
			throw new MissingInputException("The date that your bike was stolen could not be processed.  Please try again.");
		}
		return theftDate;
	}

	@Override
	protected String getDataAccessMsg() {
		return dataAccessErrorMsg;
	}
}