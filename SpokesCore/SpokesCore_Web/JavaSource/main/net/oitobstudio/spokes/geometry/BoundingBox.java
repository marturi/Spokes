package net.oitobstudio.spokes.geometry;

import com.vividsolutions.jts.algorithm.SimplePointInRing;
import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.Envelope;
import com.vividsolutions.jts.geom.Geometry;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.LinearRing;

public class BoundingBox {
	private double minx;
	private double miny;
	private double maxx;
	private double maxy;

	public Coordinate getCenterPoint(GeometryFactory geometryFactory){
		Coordinate centerPoint = null;
		Coordinate[] bbCoords = makeRingCoordinates(minx, miny, maxx, maxy);
		LinearRing globalBB = geometryFactory.createLinearRing(bbCoords);
		if(globalBB != null){
			centerPoint = globalBB.getCentroid().getCoordinate();
		}
		return centerPoint;
	}

	public Envelope getEnvelope(GeometryFactory geometryFactory) {
		Envelope env = null;
		Coordinate[] bbCoords = makeRingCoordinates(minx, miny, maxx, maxy);
		LinearRing globalBB = geometryFactory.createLinearRing(bbCoords);
		if(globalBB != null){
			env = globalBB.getEnvelopeInternal();
		}
		return env;
	}

	public Geometry getIntersection(GeometryFactory geometryFactory, 
			Geometry otherGeometry){
		Geometry intersection = null;
		Coordinate[] bbCoords = makeRingCoordinates(minx, miny, maxx, maxy);
		LinearRing globalBB = geometryFactory.createLinearRing(bbCoords);
		if(globalBB != null && otherGeometry != null){
			intersection = globalBB.intersection(otherGeometry);
		}
		return intersection;
	}

	public static LinearRing makeBoundingBox(GeometryFactory geometryFactory, 
			double minX, double minY, double maxX, double maxY){
		Coordinate[] bbCoords = makeRingCoordinates(minX, minY, maxX, maxY);
		return geometryFactory.createLinearRing(bbCoords);
	}

	public static LinearRing makeBoundingBox(GeometryFactory geometryFactory, 
			Coordinate topLeft, Coordinate bottomRight){
		double minX = Math.min(topLeft.x, bottomRight.x);
		double minY = Math.min(topLeft.y, bottomRight.y);
		double maxX = Math.max(topLeft.x, bottomRight.x);
		double maxY = Math.max(topLeft.y, bottomRight.y);
		return makeBoundingBox(geometryFactory, minX, minY, maxX, maxY);
	}

	private static Coordinate[] makeRingCoordinates(double minX, double minY, double maxX, double maxY){
		Coordinate lowerLeft = new Coordinate(minX, minY);
		Coordinate upperLeft = new Coordinate(minX, maxY);
		Coordinate lowerRight = new Coordinate(maxX, minY);
		Coordinate upperRight = new Coordinate(maxX, maxY);
		Coordinate[] bbCoords = {lowerLeft, upperLeft, upperRight, lowerRight, lowerLeft};
		return bbCoords;
	}

	public static boolean isPointInBoundingBox(GeometryFactory geometryFactory, Coordinate pt, BoundingBox bb){
		Coordinate[] bbCoords = makeRingCoordinates(bb.minx, bb.miny, bb.maxx, bb.maxy);
		LinearRing lr = geometryFactory.createLinearRing(bbCoords);
		SimplePointInRing pointInRing = new SimplePointInRing(lr);
		return pointInRing.isInside(pt);
	}

	public static boolean isPointInBoundingBox(GeometryFactory geometryFactory, Coordinate pt, LinearRing lr){
		SimplePointInRing pointInRing = new SimplePointInRing(lr);
		return pointInRing.isInside(pt);
	}

	public static LinearRing makeBoundingGeometryForPoint(GeometryFactory geometryFactory, Coordinate coordinate, double buffer){
		Coordinate[] bbCoords = makeRingCoordinates(coordinate.x-buffer, coordinate.y-buffer, coordinate.x+buffer, coordinate.y+buffer);
		return geometryFactory.createLinearRing(bbCoords);
	}

	@Override
	public String toString() {
		return "MinX:" + minx + ", MinY:" + miny + ", MaxX:" + maxx + ", MaxY:" + maxy;
	}
}