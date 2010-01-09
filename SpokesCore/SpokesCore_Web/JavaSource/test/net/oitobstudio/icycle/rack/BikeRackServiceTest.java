package net.oitobstudio.icycle.rack;

import java.io.StringWriter;

import javax.xml.transform.Result;
import javax.xml.transform.stream.StreamResult;

import net.oitobstudio.spokes.SpokesException;
import net.oitobstudio.spokes.PointOutOfBoundsException;
import net.oitobstudio.spokes.rack.BikeRack;
import net.oitobstudio.spokes.rack.BikeRackCriteria;
import net.oitobstudio.spokes.rack.BikeRackService;
import net.oitobstudio.spokes.rack.BikeRacks;

import org.junit.Test;
import static org.junit.Assert.*;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.oxm.castor.CastorMarshaller;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations={"/META-INF/spring/bikeRackService.xml", "/META-INF/spring/spokesHibernateTemplate.xml", "/testDataSource.xml", "/META-INF/spring/commonContext.xml"})

public class BikeRackServiceTest{
	@Autowired
	private BikeRackService bikeRackService;
	@Autowired
	private CastorMarshaller castorMarshaller;

	@Test
	public void testGetNearestBikeRacks() throws Exception{
		String topLeft = "-73.99423484, 40.64027808";
		String bottomRight = "-73.97709393, 40.63086132";
		BikeRackCriteria criteria = new BikeRackCriteria(topLeft, bottomRight, null);
		BikeRacks nearestRacks = bikeRackService.findNearestBikeRacks(criteria);
		System.out.println("Found " + nearestRacks.getBikeRacks().size() + " racks.");
		StringWriter myWriter = new StringWriter();
		Result sResult = new StreamResult(myWriter);
		castorMarshaller.marshal(nearestRacks, sResult);
        System.out.println(myWriter.getBuffer().toString());
	}

	@Test
	public void testGetBikeRackDetail() throws Exception{
		BikeRack rack = bikeRackService.getBikeRackDetail(1);
		StringWriter myWriter = new StringWriter();
		Result sResult = new StreamResult(myWriter);
		castorMarshaller.marshal(rack, sResult);
        System.out.println(myWriter.getBuffer().toString());
	}

	@Test
	public void testAddRackPositive() throws Exception {
		BikeRack newRack = new BikeRack("-73.9528557346964,40.6022703701773","My Rack Address");
		bikeRackService.addBikeRack(newRack);
	}
}