package net.oitobstudio.spokes.shop.ws;

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
import net.oitobstudio.spokes.shop.BikeShop;
import net.oitobstudio.spokes.shop.BikeShopCriteria;
import net.oitobstudio.spokes.shop.BikeShopService;
import net.oitobstudio.spokes.shop.BikeShops;
import net.oitobstudio.spokes.ws.SpokesBaseController;

@Controller
public class BikeShopController extends SpokesBaseController{
	private static Logger log = Logger.getLogger(BikeShopController.class);
	private BikeShopService bikeShopService;

	@Autowired
	public BikeShopController(BikeShopService bikeShopService) {
		this.bikeShopService = bikeShopService;
	}

	@RequestMapping(value="/shops/{topLeft}_{bottomRight}", method=RequestMethod.GET)
	public ModelAndView getNearestShops(@PathVariable("topLeft") String topLeft,
			@PathVariable("bottomRight") String bottomRight,
			HttpServletResponse response) {
		BikeShops nearestShops = null;
		ModelAndView mav = new ModelAndView("marshaller");
		try{
			BikeShopCriteria criteria = new BikeShopCriteria(topLeft, bottomRight, null);
			nearestShops = bikeShopService.findNearestBikeShops(criteria);
			mav.addObject("SpokesResult", nearestShops);
		}catch(SpokesException e){
			log.error(e);
			mav.addObject("SpokesResult", new BikeShops(e.getFault()));
			super.addFaultHeader(response);
		}
		return mav;
	}

	@RequestMapping(value="/shop/{bikeShopId}", method=RequestMethod.GET)
	public ModelAndView getShopDetail(@PathVariable("bikeShopId") long bikeShopId) {
		ModelAndView mav = new ModelAndView("marshaller");
		BikeShop bikeShop = bikeShopService.getBikeShopDetail(bikeShopId);
		mav.addObject("SpokesResult", new BikeShops(bikeShop));
		return mav;
	}

	@RequestMapping(value="/shop", method=RequestMethod.POST)
	public ModelAndView addBikeRack(@RequestBody MultiValueMap<String,Object> addShopParams, 
			HttpServletRequest request,
			HttpServletResponse response) {
		String shopCoordinate = (String)addShopParams.getFirst("shopCoordinate");
		String shopAddress = (String)addShopParams.getFirst("shopAddress");
		String shopName = (String)addShopParams.getFirst("shopName");
		String shopPhone = (String)addShopParams.getFirst("shopPhone");
		String hasRentalsStr = (String)addShopParams.getFirst("hasRentals");
		Character hasRentals = null;
		if("Y".equals(hasRentalsStr)){
			hasRentals = 'Y';
		}else if("N".equals(hasRentalsStr)){
			hasRentals = 'N';
		}
		ModelAndView mav = new ModelAndView("marshaller");
		try{
			BikeShop newShop = new BikeShop(shopName, shopAddress, shopPhone, shopCoordinate, hasRentals);
			bikeShopService.addBikeShop(newShop);
			SpokesConfirm confirm = new SpokesConfirm("The bike shop has been successfully added.");
			mav.addObject("SpokesResult", confirm);
			response.setStatus(HttpServletResponse.SC_CREATED);
			StringBuffer uri = request.getRequestURL();
			uri.append("/");
			uri.append(newShop.getId());
			response.setHeader("Location", uri.toString());
			response.setContentType("text/xml");
		}catch(SpokesException e){
			log.error(e);
			response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
			mav.addObject("SpokesResult", new BikeShops(e.getFault()));
		}
		return mav;
	}

	@Override
	protected String getDataAccessMsg() {
		return "An error occurred while retrieving the bike shop info.  Please try again.";
	}
}