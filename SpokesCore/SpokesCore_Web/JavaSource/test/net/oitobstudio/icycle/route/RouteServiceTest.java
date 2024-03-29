package net.oitobstudio.icycle.route;

import java.io.StringWriter;
import java.util.Map;
import java.util.List;

import javax.xml.transform.Result;
import javax.xml.transform.stream.StreamResult;

import net.oitobstudio.spokes.geometry.BoundingBox;
import net.oitobstudio.spokes.geometry.BoundingBoxRepository;
import net.oitobstudio.spokes.route.BookendRouteSegment;
import net.oitobstudio.spokes.route.Route;
import net.oitobstudio.spokes.route.RouteCriteria;
import net.oitobstudio.spokes.route.RouteSegment;
import net.oitobstudio.spokes.route.RouteSegmentRepository;
import net.oitobstudio.spokes.route.RouteService;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.oxm.castor.CastorMarshaller;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.vividsolutions.jts.geom.Coordinate;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations={"/routeService.xml", "/spokesHibernateTemplate.xml", "/testDataSource.xml", "/commonContext.xml"})

public class RouteServiceTest{
	@Autowired
    private RouteService routeService;
	@Autowired
	private RouteSegmentRepository routeSegmentRepository;
	@Autowired
	private BoundingBoxRepository boundingBoxRepository;
	@Autowired
	private CastorMarshaller castorMarshaller;

	@Test
	public void testGetClosestEdge() throws Exception{
		//Coordinate startPoint = new Coordinate(-73.9808921,40.7534881);-73.9520084,40.8516544
		Coordinate startPoint = new Coordinate(-74.00298013270896,40.72691965167061);
		List<BookendRouteSegment> closestEdges = routeSegmentRepository.findClosestEdges(startPoint);
		//System.out.println(closestEdges.get(0).getStreet());
	}

	@Test
	public void testGlobalBoundingBox() throws Exception{
		BoundingBox globalBBox = boundingBoxRepository.findGlobalBoundingBox();
		System.out.println(globalBBox);
	}

	@Test
	public void testGetShortestPathRoute() throws Exception{
		//-73.983911,40.674180  -73.983237,40.672976
		String startCoord = "-74.00298013270896,40.726920";
		String endCoord = "-74.002070,40.728059";
		Map<String, String> options = null;
		RouteCriteria criteria = new RouteCriteria(startCoord, endCoord, options);
		Route route = routeService.getShortestPathRoute(criteria);
		StringWriter myWriter = new StringWriter();
		Result sResult = new StreamResult(myWriter);
		castorMarshaller.marshal(route, sResult);
        System.out.println(myWriter.getBuffer().toString());
	}

	public static float distFrom(float lat1, float lng1, float lat2, float lng2) {
	    double earthRadius = 3958.75;
	    double dLat = Math.toRadians(lat2-lat1);
	    double dLng = Math.toRadians(lng2-lng1);
	    double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
	               Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
	               Math.sin(dLng/2) * Math.sin(dLng/2);
	    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
	    double dist = earthRadius * c;

	    int meterConversion = 1609;

	    return new Float(dist * meterConversion).floatValue();
	}
}