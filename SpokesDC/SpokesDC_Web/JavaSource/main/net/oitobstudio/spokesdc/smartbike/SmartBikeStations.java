package net.oitobstudio.spokesdc.smartbike;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import net.oitobstudio.spokes.SpokesFault;

public class SmartBikeStations {
	private List<SmartBikeStation> smartBikeStations;
	private SpokesFault smartBikeStationFault;

	public SmartBikeStations() {}
	
	public SmartBikeStations(List<SmartBikeStation> smartBikeStations){
		this.smartBikeStations = smartBikeStations;
	}

	public SmartBikeStations(SmartBikeStation smartBikeStation){
		smartBikeStations = new ArrayList<SmartBikeStation>();
		if(smartBikeStation != null){
			smartBikeStations.add(smartBikeStation);
		}
	}

	public SmartBikeStations(SpokesFault smartBikeStationFault){
		this.smartBikeStationFault = smartBikeStationFault;
	}

	public List<SmartBikeStation> getSmartBikeStations() {
		return Collections.unmodifiableList(smartBikeStations);
	}

	public SpokesFault getSmartBikeStationFault() {
		return smartBikeStationFault;
	}
}