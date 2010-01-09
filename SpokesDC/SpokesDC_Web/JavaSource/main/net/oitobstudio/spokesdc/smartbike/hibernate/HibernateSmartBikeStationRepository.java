package net.oitobstudio.spokesdc.smartbike.hibernate;

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

import net.oitobstudio.spokesdc.smartbike.SmartBikeStation;
import net.oitobstudio.spokesdc.smartbike.SmartBikeStationRepository;

@Repository
@SuppressWarnings("unchecked")
public class HibernateSmartBikeStationRepository extends HibernateDaoSupport implements SmartBikeStationRepository {
	private final Type geometryType;
	private GeometryFactory geometryFactory;

	public HibernateSmartBikeStationRepository(HibernateTemplate template) {
		setHibernateTemplate(template);
		geometryType = new CustomType(GeometryUserType.class, null);
	}

	public List<SmartBikeStation> findNearestSmartBikeStations(final Coordinate coordinate) {
		List<SmartBikeStation> nearestSmartBikeStations =  getHibernateTemplate().execute(new HibernateCallback<List<SmartBikeStation>>() {
			public List<SmartBikeStation> doInHibernate(Session session) throws HibernateException,
					SQLException {
				Query q = session.getNamedQuery("nearestSmartBikeStations");
				q.setParameter("coordinate", geometryFactory.createPoint(coordinate), geometryType);
				return q.list();
			}
		});
		return nearestSmartBikeStations;
	}

	@Transactional(readOnly=true)
	public SmartBikeStation findSmartBikeStation(long stationId){
		SmartBikeStation station = getHibernateTemplate().load(SmartBikeStation.class, stationId);
		getHibernateTemplate().initialize(station);
		return station;
	}

	public void setGeometryFactory(GeometryFactory geometryFactory){
		this.geometryFactory = geometryFactory;
	}
}