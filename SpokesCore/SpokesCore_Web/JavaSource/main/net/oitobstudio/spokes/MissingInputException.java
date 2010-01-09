package net.oitobstudio.spokes;

public class MissingInputException extends SpokesException {
	private static final long serialVersionUID = -357433429397284491L;
	private String faultMsg;

	public MissingInputException(String message) {
		super(message);
		this.faultMsg = message;
	}

	@Override
	public SpokesFault getFault() {
		return new SpokesFault(faultMsg);
	}
}