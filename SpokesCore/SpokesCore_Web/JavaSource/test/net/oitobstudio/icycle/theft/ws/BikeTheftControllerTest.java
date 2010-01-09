package net.oitobstudio.icycle.theft.ws;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations={"/icycle-servlet.xml", "/bikeTheftService.xml", "/iCycleHibernateTemplate.xml", "/testDataSource.xml", "/commonContext.xml"})

public class BikeTheftControllerTest {

	@Test
	public void testReportTheft() throws Exception{
		String theftLocation = "-73.9198569365887,40.60710075975837";
		MockHttpServletRequest req = new MockHttpServletRequest("POST", "http://localhost:8080/iCycle_Web/icycle/thefts");
		req.addParameter("theftCoordinate", theftLocation);
		req.addParameter("comments", "Help, my bike was stolen!");
		req.addParameter("theftDate", "12-03-1974");
	}
}