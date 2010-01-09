package net.oitobstudio.spokesdc.trail.hibernate;

import org.hibernate.type.CustomType;
import org.hibernate.type.Type;
import org.hibernatespatial.GeometryUserType;
import org.springframework.orm.hibernate3.HibernateTemplate;
import org.springframework.orm.hibernate3.support.HibernateDaoSupport;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import net.oitobstudio.spokesdc.trail.TrailSegment;
import net.oitobstudio.spokesdc.trail.TrailSegmentRepository;

@Repository
public class HibernateTrailSegmentRepository extends HibernateDaoSupport implements TrailSegmentRepository {

	private final Type geometryType;

	public HibernateTrailSegmentRepository(HibernateTemplate template) {
		setHibernateTemplate(template);
		geometryType = new CustomType(GeometryUserType.class, null);
	}

	@Transactional(readOnly=true)
	public TrailSegment findTrailSegment(long id) {
		return getHibernateTemplate().load(TrailSegment.class, id);
	}

	public void delete(TrailSegment trailSegment) {
		getHibernateTemplate().delete(trailSegment);
	}
}