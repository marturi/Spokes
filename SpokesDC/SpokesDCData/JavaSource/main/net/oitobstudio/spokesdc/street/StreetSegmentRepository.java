package net.oitobstudio.spokesdc.street;

public interface StreetSegmentRepository {
	public StreetSegment findStreetSegment(long id);
	public void delete(StreetSegment streetSegment);
	public void save(StreetSegment streetSegment);
}