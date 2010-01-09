package net.oitobstudio.spokes.geometry.hibernate;

import java.util.List;
import java.sql.SQLException;

import net.oitobstudio.spokes.geometry.BoundingBox;
import net.oitobstudio.spokes.geometry.BoundingBoxRepository;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Query;
import org.hibernate.transform.Transformers;

import org.springframework.orm.hibernate3.HibernateCallback;
import org.springframework.orm.hibernate3.HibernateTemplate;
import org.springframework.orm.hibernate3.support.HibernateDaoSupport;

@SuppressWarnings("unchecked")
public class HibernateBoundingBoxRepository extends HibernateDaoSupport implements BoundingBoxRepository{
	private BoundingBox globalBoundingBox;
	private String streetEdgesTableName;

	public HibernateBoundingBoxRepository(HibernateTemplate template, String streetEdgesTableName){
		setHibernateTemplate(template);
		this.streetEdgesTableName = streetEdgesTableName;
	}

	public void initBoundingBoxRepository(){
		if(globalBoundingBox == null){
			globalBoundingBox = findGlobalBoundingBox();
		}
	}

	public BoundingBox findGlobalBoundingBox() {
		if(globalBoundingBox == null){
			globalBoundingBox = getHibernateTemplate().execute(new HibernateCallback<BoundingBox>(){
				public BoundingBox doInHibernate(Session session) throws HibernateException, SQLException {
					StringBuffer q = new StringBuffer();
					q.append("SELECT ST_XMin(env)-.005 as minx, ST_YMin(env)-.005 as miny, ST_XMax(env)+.005 as maxx, ST_YMax(env)+.005 as maxy ");
					q.append("FROM (SELECT ST_Extent(wkb_geometry) AS env FROM ").append(streetEdgesTableName).append(") AS sub");
					Query sqlQuery = session.createSQLQuery(q.toString()).setResultTransformer(Transformers.aliasToBean(BoundingBox.class));
					BoundingBox bb = null;
					List<BoundingBox> res = sqlQuery.list();
					if(!res.isEmpty()){
						bb = res.get(0);
					}
					return bb;
				}
			});
		}
		return globalBoundingBox;
	}
}
