package net.oitobstudio.spokes;


public abstract class SpokesException extends Exception {
	private static final long serialVersionUID = -6851250651457771971L;

	public SpokesException(String message){
		super(message);
	}

	public abstract SpokesFault getFault();
}