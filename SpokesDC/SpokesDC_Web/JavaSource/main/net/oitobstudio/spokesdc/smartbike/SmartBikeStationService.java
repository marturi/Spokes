package net.oitobstudio.spokesdc.smartbike;

import org.springframework.dao.DataAccessException;

import net.oitobstudio.spokes.SpokesException;

public interface SmartBikeStationService {
	public SmartBikeStations findNearestSmartBikeStations(SmartBikeStationCriteria criteria) throws SpokesException, DataAccessException;
	public SmartBikeStation getSmartBikeStationDetail(long stationId) throws DataAccessException;
}