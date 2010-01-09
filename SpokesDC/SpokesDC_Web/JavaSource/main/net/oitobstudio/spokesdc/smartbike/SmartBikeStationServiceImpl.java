package net.oitobstudio.spokesdc.smartbike;

import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;

import net.oitobstudio.spokes.SpokesException;
import net.oitobstudio.spokes.geometry.BoundingBox;
import net.oitobstudio.spokes.geometry.BoundingBoxRepository;
import net.oitobstudio.spokes.geometry.GeometryUtils;

import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.LinearRing;

public class SmartBikeStationServiceImpl implements SmartBikeStationService {
	private GeometryFactory geometryFactory;
	private BoundingBoxRepository boundingBoxRepository;
	private SmartBikeStationRepository smartBikeStationRepository;
	private static Logger log = Logger.getLogger(SmartBikeStationServiceImpl.class);

	public SmartBikeStations findNearestSmartBikeStations(SmartBikeStationCriteria criteria) throws SpokesException {
		criteria.validateSmartBikeStationCriteria(geometryFactory);
		LinearRing searchArea = criteria.getBoundingBox(geometryFactory);
		List<SmartBikeStation> filteredStations = null;
		if(searchArea != null){
			List<SmartBikeStation> stations = smartBikeStationRepository.findNearestSmartBikeStations(searchArea.getCentroid().getCoordinate());
			filteredStations = filterStations(stations, searchArea);
		}
		return new SmartBikeStations(filteredStations);
	}

	private List<SmartBikeStation> filterStations(List<SmartBikeStation> unfilteredStations, LinearRing searchArea){
		List<SmartBikeStation> filteredStations = new ArrayList<SmartBikeStation>();
		if(unfilteredStations != null && !unfilteredStations.isEmpty()){
			for(SmartBikeStation station : unfilteredStations){
				if(filteredStations.size() == 10){
					break;
				}else{
					Coordinate rackCoordinate = GeometryUtils.parseCoordinate(station.getStationCoordinate());
					if(BoundingBox.isPointInBoundingBox(geometryFactory, rackCoordinate, searchArea)){
						filteredStations.add(station);
					}
				}
			}
			if(filteredStations.isEmpty()){
				filteredStations.add(unfilteredStations.get(0));
			}
		}
		return filteredStations;
	}

	public SmartBikeStation getSmartBikeStationDetail(long stationId) {
		return smartBikeStationRepository.findSmartBikeStation(stationId);
	}

	public void setSmartBikeStationRepository(SmartBikeStationRepository smartBikeStationRepository) {
		this.smartBikeStationRepository = smartBikeStationRepository;
	}

	public void setBoundingBoxRepository(BoundingBoxRepository boundingBoxRepository) {
		this.boundingBoxRepository = boundingBoxRepository;
	}

	public void setGeometryFactory(GeometryFactory geometryFactory){
		this.geometryFactory = geometryFactory;
	}
}