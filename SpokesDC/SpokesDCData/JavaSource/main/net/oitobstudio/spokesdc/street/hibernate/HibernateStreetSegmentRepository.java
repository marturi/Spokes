package net.oitobstudio.spokesdc.street.hibernate;

import org.hibernate.type.CustomType;
import org.hibernate.type.Type;
import org.hibernatespatial.GeometryUserType;
import org.springframework.orm.hibernate3.HibernateTemplate;
import org.springframework.orm.hibernate3.support.HibernateDaoSupport;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.vividsolutions.jts.geom.GeometryFactory;

import net.oitobstudio.spokesdc.street.StreetSegment;
import net.oitobstudio.spokesdc.street.StreetSegmentRepository;

@Repository
public class HibernateStreetSegmentRepository extends HibernateDaoSupport implements StreetSegmentRepository {

	private GeometryFactory geometryFactory;
	private final Type geometryType;

	public HibernateStreetSegmentRepository(HibernateTemplate template) {
		setHibernateTemplate(template);
		geometryType = new CustomType(GeometryUserType.class, null);
	}

	@Transactional(readOnly=true)
	public StreetSegment findStreetSegment(long id) {
		return getHibernateTemplate().load(StreetSegment.class, id);
	}

	public void delete(StreetSegment streetSegment) {
		getHibernateTemplate().delete(streetSegment);
	}

	public void save(StreetSegment streetSegment) {
		getHibernateTemplate().saveOrUpdate(streetSegment);
	}

	public void setGeometryFactory(GeometryFactory geometryFactory){
		this.geometryFactory = geometryFactory;
	}
}