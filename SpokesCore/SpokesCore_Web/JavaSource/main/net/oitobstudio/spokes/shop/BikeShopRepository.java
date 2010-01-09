package net.oitobstudio.spokes.shop;

import java.util.List;

import com.vividsolutions.jts.geom.Coordinate;

public interface BikeShopRepository {
	public List<BikeShop> findNearestBikeShops(Coordinate currentLocation);
	public BikeShop findBikeShop(long shopId);
}