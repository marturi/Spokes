package net.oitobstudio.spokes;

public class PointOutOfBoundsException extends SpokesException {
	private static final long serialVersionUID = -7491708900360707361L;
	private String faultMsg;

	public PointOutOfBoundsException(String message, String faultMsg) {
		super(message);
		this.faultMsg = faultMsg;
	}

	@Override
	public SpokesFault getFault() {
		return new SpokesFault(faultMsg);
	}
}