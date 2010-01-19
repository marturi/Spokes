package net.oitobstudio.spokes.shop.hibernate;

import java.math.BigInteger;
import java.sql.SQLException;
import java.util.List;

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

import net.oitobstudio.spokes.shop.BikeShop;
import net.oitobstudio.spokes.shop.BikeShopRepository;

@Repository
@Transactional(readOnly=true)
@SuppressWarnings("unchecked")
public class HibernateBikeShopRepository extends HibernateDaoSupport implements BikeShopRepository {
	private final Type geometryType;
	private GeometryFactory geometryFactory;
	private String bikeShopTableName;
	private String utmSrid;

	public HibernateBikeShopRepository(HibernateTemplate template) {
		setHibernateTemplate(template);
		geometryType = new CustomType(GeometryUserType.class, null);
	}

	@Transactional(readOnly=false)
	public void save(BikeShop shop){
		getHibernateTemplate().saveOrUpdate(shop);
	}

	public List<BikeShop> findNearestBikeShops(final Coordinate coordinate) {
		List<BikeShop> nearestShops =  getHibernateTemplate().execute(new HibernateCallback<List<BikeShop>>() {
			public List<BikeShop> doInHibernate(Session session) throws HibernateException,
					SQLException {
				Query q = session.getNamedQuery("nearestShops");
				q.setParameter("coordinate", geometryFactory.createPoint(coordinate), geometryType);
				return q.list();
			}
		});
		return nearestShops;
	}

	public BikeShop findBikeShop(long shopId) {
		return getHibernateTemplate().load(BikeShop.class, shopId);
	}

	public boolean isDuplicateShop(final BikeShop newShop) {
		BigInteger count = getHibernateTemplate().execute(new HibernateCallback<BigInteger>(){
			public BigInteger doInHibernate(Session session) throws HibernateException, SQLException {
				Coordinate shopLocation = newShop.getShopPoint().getCoordinate();
				String shopName = newShop.getShopName().replaceAll("'","\\\\'");
				StringBuffer q = new StringBuffer();
				q.append("select count(*) from ").append(bikeShopTableName);
				q.append(" where st_distance(st_transform(wkb_geometry, ").append(utmSrid).append("), st_transform(st_setsrid(st_makepoint(");
				q.append(shopLocation.x).append(",").append(shopLocation.y).append("),4326),").append(utmSrid).append(")) < 10");
				q.append(" and st_transform(wkb_geometry, ").append(utmSrid).append(") && st_expand(st_transform(st_setsrid(st_makepoint(");
				q.append(shopLocation.x).append(",").append(shopLocation.y).append("),4326),").append(utmSrid).append("),100)");
				q.append(" and upper(shop_name) = upper('").append(shopName).append("') ");
				if(newShop.getPhoneNumber() != null){
					q.append(" and upper(phone) = upper('").append(newShop.getPhoneNumber()).append("') ");
				}
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

	public void setBikeShopTableName(String bikeShopTableName) {
		this.bikeShopTableName = bikeShopTableName;
	}

	public void setUtmSrid(String utmSrid) {
		this.utmSrid = utmSrid;
	}
}