package net.oitobstudio.spokes.theft;

import org.springframework.dao.DataAccessException;

import net.oitobstudio.spokes.SpokesException;

public interface BikeTheftService {
	public void reportBikeTheft(BikeTheft bikeTheft) throws SpokesException, DataAccessException;
	public BikeThefts getNearbyBikeThefts(BikeTheftCriteria bikeTheftCriteria) throws SpokesException, DataAccessException;
	public BikeTheft getBikeTheftDetail(long bikeTheftId) throws DataAccessException;
}