package net.oitobstudio.spokes.shop;

import java.util.ArrayList;
import java.util.List;

import net.oitobstudio.spokes.SpokesFault;

public class BikeShops {
	private List<BikeShop> bikeShops;
	private SpokesFault bikeShopFault;

	public BikeShops() {}

	public BikeShops(List<BikeShop> bikeShops){
		this.bikeShops = bikeShops;
	}

	public BikeShops(BikeShop bikeShop){
		bikeShops = new ArrayList<BikeShop>();
		if(bikeShop != null){
			bikeShops.add(bikeShop);
		}
	}

	public BikeShops(SpokesFault bikeShopFault){
		this.bikeShopFault = bikeShopFault;
	}

	public List<BikeShop> getBikeShops() {
		return bikeShops;
	}

	public SpokesFault getBikeShopFault() {
		return bikeShopFault;
	}
}