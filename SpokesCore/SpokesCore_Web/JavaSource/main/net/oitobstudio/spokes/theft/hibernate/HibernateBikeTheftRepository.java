package net.oitobstudio.spokes.theft.hibernate;

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

import net.oitobstudio.spokes.theft.BikeTheft;
import net.oitobstudio.spokes.theft.BikeTheftRepository;

@Repository
@Transactional(readOnly=true)
@SuppressWarnings("unchecked")
public class HibernateBikeTheftRepository extends HibernateDaoSupport implements BikeTheftRepository {
	private final Type geometryType;
	private GeometryFactory geometryFactory;

	public HibernateBikeTheftRepository(HibernateTemplate template) {
		setHibernateTemplate(template);
		geometryType = new CustomType(GeometryUserType.class, null);
	}

	@Transactional(readOnly=false)
	public void save(BikeTheft bikeTheft) {
		getHibernateTemplate().saveOrUpdate(bikeTheft);
	}

	public List<BikeTheft> findNearbyBikeThefts(final Coordinate currentLocation) {
		List<BikeTheft> nearbyThefts =  getHibernateTemplate().execute(new HibernateCallback<List<BikeTheft>>() {
			public List<BikeTheft> doInHibernate(Session session) throws HibernateException,
					SQLException {
				Query q = session.getNamedQuery("nearbyThefts");
				q.setParameter("currentLocation", geometryFactory.createPoint(currentLocation), geometryType);
				return q.list();
			}
		});
		return nearbyThefts;
	}

	public BikeTheft findBikeTheft(long theftId) {
		return getHibernateTemplate().load(BikeTheft.class, theftId);
	}

	public void setGeometryFactory(GeometryFactory geometryFactory){
		this.geometryFactory = geometryFactory;
	}
}