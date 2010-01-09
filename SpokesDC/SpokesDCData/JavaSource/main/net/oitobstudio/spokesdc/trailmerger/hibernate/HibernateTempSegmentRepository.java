package net.oitobstudio.spokesdc.trailmerger.hibernate;

import org.springframework.orm.hibernate3.HibernateTemplate;
import org.springframework.orm.hibernate3.support.HibernateDaoSupport;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import net.oitobstudio.spokesdc.trailmerger.TempSegment;
import net.oitobstudio.spokesdc.trailmerger.TempSegmentRepository;

@Repository
public class HibernateTempSegmentRepository extends HibernateDaoSupport implements TempSegmentRepository {

	public HibernateTempSegmentRepository(HibernateTemplate template) {
		setHibernateTemplate(template);
	}

	public void save(TempSegment tempSegment) {
		getHibernateTemplate().saveOrUpdate(tempSegment);
	}
}