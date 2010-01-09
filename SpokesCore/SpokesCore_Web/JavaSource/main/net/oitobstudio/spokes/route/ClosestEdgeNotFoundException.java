package net.oitobstudio.spokes.route;

import net.oitobstudio.spokes.SpokesException;
import net.oitobstudio.spokes.SpokesFault;

public class ClosestEdgeNotFoundException extends SpokesException {
	private static final long serialVersionUID = -5937806820583777021L;
	public static final int START = 0;
	public static final int END = 1;
	private int edgeNotFound;

	public ClosestEdgeNotFoundException(String message, int edgeNotFound){
		super(message);
		this.edgeNotFound = edgeNotFound;
	}

	@Override
	public SpokesFault getFault() {
		String faultMsg = null;
		if(edgeNotFound == START){
			faultMsg = "No street was found near the start address that was entered.";
		}else{
			faultMsg = "No street was found near the destination address that was entered.";
		}
		return new SpokesFault(faultMsg);
	}
}
