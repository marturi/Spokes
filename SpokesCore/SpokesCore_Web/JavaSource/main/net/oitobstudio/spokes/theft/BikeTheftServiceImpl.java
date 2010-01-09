package net.oitobstudio.spokes.theft;

import java.util.ArrayList;
import java.util.List;

import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.LinearRing;

import net.oitobstudio.spokes.SpokesException;
import net.oitobstudio.spokes.geometry.BoundingBox;
import net.oitobstudio.spokes.geometry.BoundingBoxRepository;
import net.oitobstudio.spokes.geometry.GeometryUtils;

public class BikeTheftServiceImpl implements BikeTheftService {
	private GeometryFactory geometryFactory;
	private BoundingBoxRepository boundingBoxRepository;
	private BikeTheftRepository bikeTheftRepository;

	public void reportBikeTheft(BikeTheft bikeTheft) throws SpokesException {
		if(bikeTheft != null) {
			bikeTheft.makeTheftPoint(geometryFactory, boundingBoxRepository.findGlobalBoundingBox());
			bikeTheftRepository.save(bikeTheft);
		}
	}

	public BikeThefts getNearbyBikeThefts(BikeTheftCriteria bikeTheftCriteria) throws SpokesException {
		bikeTheftCriteria.validateBikeTheftCriteria(geometryFactory);
		LinearRing searchArea = bikeTheftCriteria.getBoundingBox(geometryFactory);
		List<BikeTheft> filteredThefts = null;
		if(searchArea != null){
			List<BikeTheft> thefts = bikeTheftRepository.findNearbyBikeThefts(searchArea.getCentroid().getCoordinate());
			filteredThefts = filterThefts(thefts, searchArea);
		}
		return new BikeThefts(filteredThefts);
	}

	private List<BikeTheft> filterThefts(List<BikeTheft> unfilteredThefts, LinearRing searchArea){
		List<BikeTheft> filteredThefts = new ArrayList<BikeTheft>();
		if(unfilteredThefts != null && !unfilteredThefts.isEmpty()){
			for(BikeTheft theft : unfilteredThefts){
				if(filteredThefts.size() == 10){
					break;
				}else{
					Coordinate rackCoordinate = GeometryUtils.parseCoordinate(theft.getTheftCoordinate());
					if(BoundingBox.isPointInBoundingBox(geometryFactory, rackCoordinate, searchArea)){
						filteredThefts.add(theft);
					}
				}
			}
			if(filteredThefts.isEmpty()){
				filteredThefts.add(unfilteredThefts.get(0));
			}
		}
		return filteredThefts;
	}

	public BikeTheft getBikeTheftDetail(long bikeTheftId) {
		return bikeTheftRepository.findBikeTheft(bikeTheftId);
	}

	public void setBikeTheftRepository(BikeTheftRepository bikeTheftRepository) {
		this.bikeTheftRepository = bikeTheftRepository;
	}

	public void setBoundingBoxRepository(BoundingBoxRepository boundingBoxRepository) {
		this.boundingBoxRepository = boundingBoxRepository;
	}

	public void setGeometryFactory(GeometryFactory geometryFactory) {
		this.geometryFactory = geometryFactory;
	}
}