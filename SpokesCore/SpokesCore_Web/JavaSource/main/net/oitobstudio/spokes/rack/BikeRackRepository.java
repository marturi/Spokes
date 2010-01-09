package net.oitobstudio.spokes.rack;

import java.util.List;

import com.vividsolutions.jts.geom.Coordinate;

public interface BikeRackRepository {
	public void save(BikeRack rack);
	public List<BikeRack> findNearestBikeRacks(Coordinate currentLocation);
	public BikeRack findBikeRack(long rackId);
	public boolean isDuplicateRack(Coordinate rackLocation);
}