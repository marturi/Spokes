package net.oitobstudio.spokes.theft;

import java.util.List;

import com.vividsolutions.jts.geom.Coordinate;

public interface BikeTheftRepository {
	public void save(BikeTheft bikeTheft);
	public List<BikeTheft> findNearbyBikeThefts(Coordinate currentLocation);
	public BikeTheft findBikeTheft(long theftId);
}