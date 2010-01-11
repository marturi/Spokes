package net.oitobstudio.spokes.rack.hibernate;

import java.sql.SQLException;
import java.util.List;
import java.math.BigInteger;

import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.type.CustomType;
import org.hibernate.type.Type;
import org.hibernatespatial.GeometryUserType;
import org.springframework.orm.hibernate3.HibernateCallback;
import org.springframework.orm.hibernate3.HibernateTemplate;
import org.springframework.orm.hibernate3.support.HibernateDaoSupport;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.GeometryFactory;

import net.oitobstudio.spokes.rack.BikeRack;
import net.oitobstudio.spokes.rack.BikeRackRepository;

@Repository
@Transactional(readOnly=true)
@SuppressWarnings("unchecked")
public class HibernateBikeRackRepository extends HibernateDaoSupport implements BikeRackRepository {
	private final Type geometryType;
	private GeometryFactory geometryFactory;
	private String bikeRackTableName;
	private String utmSrid;

	public HibernateBikeRackRepository(HibernateTemplate template) {
		setHibernateTemplate(template);
		geometryType = new CustomType(GeometryUserType.class, null);
	}

	@Transactional(readOnly=false)
	public void save(BikeRack rack) {
		getHibernateTemplate().saveOrUpdate(rack);
	}

	public List<BikeRack> findNearestBikeRacks(final Coordinate coordinate) {
		List<BikeRack> nearestRacks =  getHibernateTemplate().execute(new HibernateCallback<List<BikeRack>>() {
			public List<BikeRack> doInHibernate(Session session) throws HibernateException,
					SQLException {
				Query q = session.getNamedQuery("nearestRacks");
				q.setParameter("coordinate", geometryFactory.createPoint(coordinate), geometryType);
				return q.list();
			}
		});
		return nearestRacks;
	}

	public BikeRack findBikeRack(long rackId){
		BikeRack rack = getHibernateTemplate().load(BikeRack.class, rackId);
		getHibernateTemplate().initialize(rack);
		return rack;
	}

	/**
	 * select count(*) 
		from nyc_bike_racks 
		where st_distance(st_transform(wkb_geometry, 32618), st_transform(st_setsrid(st_makepoint(:coordinate),4326),32618)) &lt; 10
		and st_transform(wkb_geometry, 32618) &amp;&amp; st_expand(st_transform(st_setsrid(st_makepoint(:coordinate),4326),32618),100)
	 */
	public boolean isDuplicateRack(final Coordinate rackLocation) {
		BigInteger count = getHibernateTemplate().execute(new HibernateCallback<BigInteger>(){
			public BigInteger doInHibernate(Session session) throws HibernateException, SQLException {
				StringBuffer q = new StringBuffer();
				q.append("select count(*) from ").append(bikeRackTableName);
				q.append(" where st_distance(st_transform(wkb_geometry, ").append(utmSrid).append("), st_transform(st_setsrid(st_makepoint(");
				q.append(rackLocation.x).append(",").append(rackLocation.y).append("),4326),").append(utmSrid).append(")) < 10");
				q.append(" and st_transform(wkb_geometry, ").append(utmSrid).append(") && st_expand(st_transform(st_setsrid(st_makepoint(");
				q.append(rackLocation.x).append(",").append(rackLocation.y).append("),4326),").append(utmSrid).append("),100)");
				Query sqlQuery = session.createSQLQuery(q.toString());
				BigInteger cnt = null;
				List<BigInteger> res = sqlQuery.list();
				if(!res.isEmpty()){
					cnt = res.get(0);
				}
				return cnt;
			}
		});
		return count.doubleValue() > 0;
	}

	public void setGeometryFactory(GeometryFactory geometryFactory){
		this.geometryFactory = geometryFactory;
	}

	public void setBikeRackTableName(String bikeRackTableName) {
		this.bikeRackTableName = bikeRackTableName;
	}

	public void setUtmSrid(String utmSrid) {
		this.utmSrid = utmSrid;
	}
}