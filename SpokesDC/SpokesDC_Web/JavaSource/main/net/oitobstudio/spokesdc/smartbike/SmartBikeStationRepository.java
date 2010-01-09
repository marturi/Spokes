package net.oitobstudio.spokesdc.smartbike;

import java.util.List;

import com.vividsolutions.jts.geom.Coordinate;

public interface SmartBikeStationRepository {
	public List<SmartBikeStation> findNearestSmartBikeStations(Coordinate currentLocation);
	public SmartBikeStation findSmartBikeStation(long stationId);
}