package net.oitobstudio.spokesdc.trailmerger;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations={"/trailMergerService.xml", "/spokesDCHibernateTemplate.xml", "/spokesDCDataSource.xml"})

public class TrailMergerServiceTest{
	@Autowired
	private TrailMergerService trailMergerService;

	@Test
	public void testMergeTrailWithStreet() throws Exception{
		long trailSegId = 34144;
		long streetSegId = 28560;
		boolean isTrail = false;
		trailMergerService.mergeTrailWithStreet(trailSegId, streetSegId, isTrail);
	}

	@Test
	public void testMergeTrails() throws Exception{
		long trailSegId1 = 51;
		long trailSegId2 = 93;
		trailMergerService.mergeTrails(trailSegId1, trailSegId2);
	}

	@Test
	public void testMergeStreets() throws Exception{
		long streetSegId1 = 35293;
		long streetSegId2 = 5402;
		trailMergerService.mergeStreets(streetSegId1, streetSegId2);
	}
}