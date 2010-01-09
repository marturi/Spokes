package net.oitobstudio.spokes.rack;

import org.springframework.dao.DataAccessException;

import net.oitobstudio.spokes.SpokesException;

public interface BikeRackService {
	public void addBikeRack(BikeRack newRack) throws SpokesException, DataAccessException;
	public BikeRacks findNearestBikeRacks(BikeRackCriteria criteria) throws SpokesException, DataAccessException;
	public BikeRack getBikeRackDetail(long rackId) throws DataAccessException;
}