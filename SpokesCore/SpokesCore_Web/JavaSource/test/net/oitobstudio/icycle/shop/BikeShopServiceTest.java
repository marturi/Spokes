package net.oitobstudio.icycle.shop;

import java.io.StringWriter;

import javax.xml.transform.Result;
import javax.xml.transform.stream.StreamResult;

import net.oitobstudio.spokes.SpokesException;
import net.oitobstudio.spokes.PointOutOfBoundsException;
import net.oitobstudio.spokes.shop.BikeShop;
import net.oitobstudio.spokes.shop.BikeShopCriteria;
import net.oitobstudio.spokes.shop.BikeShopService;
import net.oitobstudio.spokes.shop.BikeShops;

import org.junit.Test;
import static org.junit.Assert.*;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.oxm.castor.CastorMarshaller;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations={"/bikeShopService.xml", "/iCycleHibernateTemplate.xml", "/testDataSource.xml", "/commonContext.xml"})

public class BikeShopServiceTest{
	@Autowired
	private BikeShopService bikeShopService;
	@Autowired
	private CastorMarshaller castorMarshaller;

	@Test
	public void testGetNearestBikeShops() throws Exception{
		String topLeft = "-73.99423484, 40.64027808";
		String bottomRight = "-73.97709393, 40.63086132";
		BikeShopCriteria criteria = new BikeShopCriteria(topLeft, bottomRight, null);
		BikeShops nearestShops = bikeShopService.findNearestBikeShops(criteria);
		System.out.println("Found " + nearestShops.getBikeShops().size() + " shops.");
		StringWriter myWriter = new StringWriter();
		Result sResult = new StreamResult(myWriter);
		castorMarshaller.marshal(nearestShops, sResult);
        System.out.println(myWriter.getBuffer().toString());
	}

	@Test
	public void testGetBikeShopDetail() throws Exception{
		BikeShop shop = bikeShopService.getBikeShopDetail(1);
		StringWriter myWriter = new StringWriter();
		Result sResult = new StreamResult(myWriter);
		castorMarshaller.marshal(shop, sResult);
        System.out.println(myWriter.getBuffer().toString());
	}
}