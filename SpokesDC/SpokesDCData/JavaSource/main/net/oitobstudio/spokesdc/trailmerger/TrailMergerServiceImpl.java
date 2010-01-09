package net.oitobstudio.spokesdc.trailmerger;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.vividsolutions.jts.algorithm.RobustLineIntersector;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.Point;
import com.vividsolutions.jts.noding.IntersectionAdder;
import com.vividsolutions.jts.noding.MCIndexNoder;
import com.vividsolutions.jts.noding.SegmentString;

import net.oitobstudio.spokesdc.street.StreetSegment;
import net.oitobstudio.spokesdc.street.StreetSegmentRepository;
import net.oitobstudio.spokesdc.trail.TrailSegment;
import net.oitobstudio.spokesdc.trail.TrailSegmentRepository;

@SuppressWarnings("unchecked")
public class TrailMergerServiceImpl implements TrailMergerService {

	private TrailSegmentRepository trailSegmentRepository;
	private StreetSegmentRepository streetSegmentRepository;
	private TempSegmentRepository tempSegmentRepository;
	private GeometryFactory geometryFactory;

	public void mergeTrailWithStreet(long trailSegmentId, long streetSegmentId, boolean isTrail) {
		List<StreetSegment> segsToDelete = new ArrayList<StreetSegment>();
		List<SegmentString> list = new ArrayList<SegmentString>();
		if(isTrail) {
			list.add(getSegmentString(trailSegmentRepository.findTrailSegment(trailSegmentId)));
		} else {
			StreetSegment seg = streetSegmentRepository.findStreetSegment(trailSegmentId);
			list.add(getSegmentString(seg));
			segsToDelete.add(seg);
		}
		StreetSegment seg2 = streetSegmentRepository.findStreetSegment(streetSegmentId);
		list.add(getSegmentString(seg2));
		segsToDelete.add(seg2);
		MCIndexNoder noder = new MCIndexNoder();
		noder.setSegmentIntersector(new IntersectionAdder(new RobustLineIntersector()));
		noder.computeNodes(list);
		Collection<SegmentString> mergedSegments = noder.getNodedSubstrings();
		for(SegmentString segStr: mergedSegments) {
			TempSegment tmpSegment = new TempSegment(segStr, geometryFactory);
			streetSegmentRepository.save(new StreetSegment(tmpSegment));
		}
		for(StreetSegment ss : segsToDelete) {
			streetSegmentRepository.delete(ss);
		}
	}

	public void mergeTrails(long trailSegmentId1, long trailSegmentId2) {
		List<SegmentString> list = new ArrayList<SegmentString>();
		TrailSegment ts1 = trailSegmentRepository.findTrailSegment(trailSegmentId1);
		list.add(getSegmentString(ts1));
		TrailSegment ts2 = trailSegmentRepository.findTrailSegment(trailSegmentId2);
		list.add(getSegmentString(ts2));
		MCIndexNoder noder = new MCIndexNoder();
		noder.setSegmentIntersector(new IntersectionAdder(new RobustLineIntersector()));
		noder.computeNodes(list);
		Collection<SegmentString> mergedSegments = noder.getNodedSubstrings();
		for(SegmentString segStr: mergedSegments) {
			TempSegment tmpSegment = new TempSegment(segStr, geometryFactory);
			streetSegmentRepository.save(new StreetSegment(tmpSegment));
		}
	}

	public void mergeStreets(long streetSegmentId1, long streetSegmentId2) {
		List<SegmentString> list = new ArrayList<SegmentString>();
		StreetSegment ts1 = streetSegmentRepository.findStreetSegment(streetSegmentId1);
		list.add(getSegmentString(ts1));
		StreetSegment ts2 = streetSegmentRepository.findStreetSegment(streetSegmentId2);
		list.add(getSegmentString(ts2));
		MCIndexNoder noder = new MCIndexNoder();
		noder.setSegmentIntersector(new IntersectionAdder(new RobustLineIntersector()));
		noder.computeNodes(list);
		Collection<SegmentString> mergedSegments = noder.getNodedSubstrings();
		for(SegmentString segStr: mergedSegments) {
			TempSegment tmpSegment = new TempSegment(segStr, geometryFactory);
			streetSegmentRepository.save(new StreetSegment(tmpSegment));
		}
		streetSegmentRepository.delete(ts1);
		streetSegmentRepository.delete(ts2);
	}

	private SegmentString getSegmentString(TrailSegment ts) {
		Map<String,Object> trailData = new HashMap<String,Object>();
		trailData.put("name", ts.getName());
		trailData.put("bikeSegType", 'P');
		trailData.put("direction", "Two way");
		return new SegmentString(ts.getEdge().getCoordinates(), trailData);
	}

	private SegmentString getSegmentString(StreetSegment ss) {
		Map<String,Object> streetData = new HashMap<String,Object>();
		streetData.put("name", ss.getStreet());
		streetData.put("bikeSegType", ss.getBikeSegType());
		streetData.put("direction", ss.getDirection());
		return new SegmentString(ss.getEdge().getCoordinates(), streetData);
	}

	public void setStreetSegmentRepository(StreetSegmentRepository streetSegmentRepository) {
		this.streetSegmentRepository = streetSegmentRepository;
	}

	public void setTrailSegmentRepository(TrailSegmentRepository trailSegmentRepository) {
		this.trailSegmentRepository = trailSegmentRepository;
	}

	public void setGeometryFactory(GeometryFactory geometryFactory) {
		this.geometryFactory = geometryFactory;
	}

	public void setTempSegmentRepository(TempSegmentRepository tempSegmentRepository) {
		this.tempSegmentRepository = tempSegmentRepository;
	}
}