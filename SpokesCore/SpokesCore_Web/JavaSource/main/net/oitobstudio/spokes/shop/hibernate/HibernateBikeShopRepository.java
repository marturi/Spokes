package net.oitobstudio.spokes.shop.hibernate;

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

import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.GeometryFactory;

import net.oitobstudio.spokes.shop.BikeShop;
import net.oitobstudio.spokes.shop.BikeShopRepository;

@SuppressWarnings("unchecked")
public class HibernateBikeShopRepository extends HibernateDaoSupport implements BikeShopRepository {
	private final Type geometryType;
	private GeometryFactory geometryFactory;

	public HibernateBikeShopRepository(HibernateTemplate template) {
		setHibernateTemplate(template);
		geometryType = new CustomType(GeometryUserType.class, null);
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

	public void setGeometryFactory(GeometryFactory geometryFactory){
		this.geometryFactory = geometryFactory;
	}
}