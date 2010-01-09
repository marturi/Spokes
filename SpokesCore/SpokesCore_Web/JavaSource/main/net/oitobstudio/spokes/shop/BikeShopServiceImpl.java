package net.oitobstudio.spokes.shop;

import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;

import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.LinearRing;

import net.oitobstudio.spokes.SpokesException;
import net.oitobstudio.spokes.geometry.BoundingBox;
import net.oitobstudio.spokes.geometry.BoundingBoxRepository;
import net.oitobstudio.spokes.geometry.GeometryUtils;

public class BikeShopServiceImpl implements BikeShopService {
	private GeometryFactory geometryFactory;
	private BoundingBoxRepository boundingBoxRepository;
	private BikeShopRepository bikeShopRepository;
	private static Logger log = Logger.getLogger(BikeShopServiceImpl.class);

	public BikeShops findNearestBikeShops(BikeShopCriteria criteria) throws SpokesException {
		criteria.validateBikeShopCriteria(geometryFactory);
		LinearRing searchArea = criteria.getBoundingBox(geometryFactory);
		List<BikeShop> filteredShops = null;
		if(searchArea != null){
			List<BikeShop> shops = bikeShopRepository.findNearestBikeShops(searchArea.getCentroid().getCoordinate());
			filteredShops = filterShops(shops, searchArea);
		}
		return new BikeShops(filteredShops);
	}

	private List<BikeShop> filterShops(List<BikeShop> unfilteredShops, LinearRing searchArea){
		List<BikeShop> filteredShops = new ArrayList<BikeShop>();
		if(unfilteredShops != null && !unfilteredShops.isEmpty()){
			for(BikeShop shop : unfilteredShops){
				if(filteredShops.size() == 10){
					break;
				}else{
					Coordinate shopCoordinate = GeometryUtils.parseCoordinate(shop.getShopCoordinate());
					if(BoundingBox.isPointInBoundingBox(geometryFactory, shopCoordinate, searchArea)){
						filteredShops.add(shop);
					}
				}
			}
			if(filteredShops.isEmpty()){
				filteredShops.add(unfilteredShops.get(0));
			}
		}
		return filteredShops;
	}

	public BikeShop getBikeShopDetail(long shopId) {
		return bikeShopRepository.findBikeShop(shopId);
	}

	public void setGeometryFactory(GeometryFactory geometryFactory) {
		this.geometryFactory = geometryFactory;
	}

	public void setBikeShopRepository(BikeShopRepository bikeShopRepository) {
		this.bikeShopRepository = bikeShopRepository;
	}

	public void setBoundingBoxRepository(BoundingBoxRepository boundingBoxRepository) {
		this.boundingBoxRepository = boundingBoxRepository;
	}
}