package net.oitobstudio.spokes;

public class SpokesFault {
	private String faultMsg;

	public SpokesFault() {}

	public SpokesFault(String faultMsg) {
		this.faultMsg = faultMsg;
	}

	public String getFaultMsg() {
		return faultMsg;
	}
}
