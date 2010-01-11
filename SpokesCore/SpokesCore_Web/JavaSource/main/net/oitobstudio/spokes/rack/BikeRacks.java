package net.oitobstudio.spokes.rack;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import net.oitobstudio.spokes.SpokesFault;

public class BikeRacks {
	private List<BikeRack> bikeRacks;
	private SpokesFault bikeRackFault;

	public BikeRacks() {}
	
	public BikeRacks(List<BikeRack> bikeRacks){
		this.bikeRacks = bikeRacks;
	}

	public BikeRacks(BikeRack bikeRack){
		bikeRacks = new ArrayList<BikeRack>();
		if(bikeRack != null){
			bikeRacks.add(bikeRack);
		}
	}

	public BikeRacks(SpokesFault bikeRackFault){
		this.bikeRackFault = bikeRackFault;
	}

	public List<BikeRack> getBikeRacks() {
		if(bikeRacks != null) {
			return Collections.unmodifiableList(bikeRacks);
		}
		return null;
	}

	public SpokesFault getBikeRackFault() {
		return bikeRackFault;
	}
}