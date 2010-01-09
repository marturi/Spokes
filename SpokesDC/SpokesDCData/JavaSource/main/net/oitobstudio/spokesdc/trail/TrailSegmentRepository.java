package net.oitobstudio.spokesdc.trail;

public interface TrailSegmentRepository {
	public TrailSegment findTrailSegment(long id);
	public void delete(TrailSegment trailSegment);
}