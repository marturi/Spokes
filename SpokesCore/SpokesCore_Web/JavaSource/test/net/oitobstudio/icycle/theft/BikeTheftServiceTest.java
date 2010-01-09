package net.oitobstudio.icycle.theft;

import java.io.StringWriter;
import java.util.Date;

import javax.xml.transform.Result;
import javax.xml.transform.stream.StreamResult;

import net.oitobstudio.spokes.theft.BikeTheft;
import net.oitobstudio.spokes.theft.BikeTheftService;

import org.junit.Test;
import static org.junit.Assert.*;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.oxm.castor.CastorMarshaller;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations={"/bikeTheftService.xml", "/iCycleHibernateTemplate.xml", "/testDataSource.xml", "/commonContext.xml"})

public class BikeTheftServiceTest{
	@Autowired
	private BikeTheftService bikeTheftService;
	@Autowired
	private CastorMarshaller castorMarshaller;

	@Test
	public void testReportTheft() throws Exception{
		String theftLocation = "-73.9198569365887, 40.60710075975837";
		BikeTheft bikeTheft = new BikeTheft(null, theftLocation, "Help, my bike was stolen!", new Date());
		bikeTheftService.reportBikeTheft(bikeTheft);
	}

	@Test
	public void testReportTheftFromRack() throws Exception{
		String theftLocation = "-73.9198569365887, 40.60710075975837";
		BikeTheft bikeTheft = new BikeTheft(new Long(1), theftLocation, "Help, my bike was stolen!", new Date());
		bikeTheftService.reportBikeTheft(bikeTheft);
	}

	@Test
	public void testGetNearbyBikeThefts() throws Exception{
//		String currentLocation = "-73.9198569365887, 40.60710075975837";
//		BikeTheftCriteria criteria = new BikeTheftCriteria(currentLocation, null);
//		BikeThefts nearebyThefts = bikeTheftService.getNearbyBikeThefts(criteria);
//		System.out.println("Found " + nearebyThefts.getBikeThefts().size() + " thefts.");
//		StringWriter myWriter = new StringWriter();
//		Result sResult = new StreamResult(myWriter);
//		castorMarshaller.marshal(nearebyThefts, sResult);
//		System.out.println(myWriter.getBuffer().toString());
	}

	@Test
	public void testGetTheftDetail() throws Exception{
		BikeTheft theft = bikeTheftService.getBikeTheftDetail(2);
		StringWriter myWriter = new StringWriter();
		Result sResult = new StreamResult(myWriter);
		castorMarshaller.marshal(theft, sResult);
        System.out.println(myWriter.getBuffer().toString());
	}
}