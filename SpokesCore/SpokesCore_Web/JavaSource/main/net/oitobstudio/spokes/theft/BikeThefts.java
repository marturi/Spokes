package net.oitobstudio.spokes.theft;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import net.oitobstudio.spokes.SpokesFault;

public class BikeThefts {
	private List<BikeTheft> bikeThefts;
	private SpokesFault bikeTheftFault;

	public BikeThefts() {}
	
	public BikeThefts(List<BikeTheft> bikeThefts){
		this.bikeThefts = bikeThefts;
	}

	public BikeThefts(BikeTheft bikeTheft){
		bikeThefts = new ArrayList<BikeTheft>();
		if(bikeTheft != null){
			bikeThefts.add(bikeTheft);
		}
	}

	public BikeThefts(SpokesFault bikeTheftFault){
		this.bikeTheftFault = bikeTheftFault;
	}

	public List<BikeTheft> getBikeThefts() {
		return Collections.unmodifiableList(bikeThefts);
	}

	public SpokesFault getBikeTheftFault() {
		return bikeTheftFault;
	}
}