package net.oitobstudio.spokes.rack;

import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.dao.DataAccessException;

import net.oitobstudio.spokes.SpokesException;
import net.oitobstudio.spokes.geometry.BoundingBox;
import net.oitobstudio.spokes.geometry.BoundingBoxRepository;
import net.oitobstudio.spokes.geometry.GeometryUtils;

import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.LinearRing;

public class BikeRackServiceImpl implements BikeRackService {
	private GeometryFactory geometryFactory;
	private BoundingBoxRepository boundingBoxRepository;
	private BikeRackRepository bikeRackRepository;
	private static Logger log = Logger.getLogger(BikeRackServiceImpl.class);

	public void addBikeRack(BikeRack newRack) throws SpokesException, DataAccessException {
		if(newRack != null){
			newRack.makeRackPoint(geometryFactory, boundingBoxRepository.findGlobalBoundingBox());
			if(!bikeRackRepository.isDuplicateRack(GeometryUtils.parseCoordinate(newRack.getRackCoordinate()))) {
				bikeRackRepository.save(newRack);
			}
		}
	}

	public BikeRacks findNearestBikeRacks(BikeRackCriteria criteria) throws SpokesException {
		criteria.validateBikeRackCriteria(geometryFactory);
		LinearRing searchArea = criteria.getBoundingBox(geometryFactory);
		List<BikeRack> filteredRacks = null;
		if(searchArea != null){
			List<BikeRack> racks = bikeRackRepository.findNearestBikeRacks(searchArea.getCentroid().getCoordinate());
			filteredRacks = filterRacks(racks, searchArea);
		}
		return new BikeRacks(filteredRacks);
	}

	private List<BikeRack> filterRacks(List<BikeRack> unfilteredRacks, LinearRing searchArea){
		List<BikeRack> filteredRacks = new ArrayList<BikeRack>();
		if(unfilteredRacks != null && !unfilteredRacks.isEmpty()){
			for(BikeRack rack : unfilteredRacks){
				if(filteredRacks.size() == 10){
					break;
				}else{
					Coordinate rackCoordinate = GeometryUtils.parseCoordinate(rack.getRackCoordinate());
					if(BoundingBox.isPointInBoundingBox(geometryFactory, rackCoordinate, searchArea)){
						filteredRacks.add(rack);
					}
				}
			}
			if(filteredRacks.isEmpty()){
				filteredRacks.add(unfilteredRacks.get(0));
			}
		}
		return filteredRacks;
	}

	public BikeRack getBikeRackDetail(long rackId) {
		return bikeRackRepository.findBikeRack(rackId);
	}

	public void setBikeRackRepository(BikeRackRepository bikeRackRepository) {
		this.bikeRackRepository = bikeRackRepository;
	}

	public void setBoundingBoxRepository(BoundingBoxRepository boundingBoxRepository) {
		this.boundingBoxRepository = boundingBoxRepository;
	}

	public void setGeometryFactory(GeometryFactory geometryFactory){
		this.geometryFactory = geometryFactory;
	}
}