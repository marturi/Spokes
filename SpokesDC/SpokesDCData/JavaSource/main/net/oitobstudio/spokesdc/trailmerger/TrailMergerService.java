package net.oitobstudio.spokesdc.trailmerger;

public interface TrailMergerService {
	public void mergeTrailWithStreet(long trailSegmentId, long streetSegmentId, boolean isTrail);
	public void mergeTrails(long trailSegmentId1, long trailSegmentId2);
	public void mergeStreets(long streetSegmentId1, long streetSegmentId2);
}
