package net.oitobstudio.spokes.shop;

import org.springframework.dao.DataAccessException;

import net.oitobstudio.spokes.SpokesException;

public interface BikeShopService {
	public BikeShops findNearestBikeShops(BikeShopCriteria criteria) throws SpokesException, DataAccessException;
	public BikeShop getBikeShopDetail(long shopId) throws DataAccessException;
}