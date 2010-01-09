package net.oitobstudio.spokes.route.hibernate;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;

import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.LinearRing;
import com.vividsolutions.jts.geom.Coordinate;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.type.CustomType;
import org.hibernate.Query;
import org.hibernate.type.Type;
import org.hibernatespatial.GeometryUserType;
import org.springframework.orm.hibernate3.HibernateCallback;
import org.springframework.orm.hibernate3.HibernateTemplate;
import org.springframework.orm.hibernate3.support.HibernateDaoSupport;

import net.oitobstudio.spokes.geometry.BoundingBox;
import net.oitobstudio.spokes.route.BookendRouteSegment;
import net.oitobstudio.spokes.route.RouteSegment;
import net.oitobstudio.spokes.route.RouteSegmentRepository;

@SuppressWarnings("unchecked")
public class HibernateRouteSegmentRepository extends HibernateDaoSupport implements RouteSegmentRepository {
	private static Logger log = Logger.getLogger(HibernateRouteSegmentRepository.class);
	private GeometryFactory geometryFactory;
	private final Type geometryType;

	public HibernateRouteSegmentRepository(HibernateTemplate template){
		setHibernateTemplate(template);
		geometryType = new CustomType(GeometryUserType.class, null);
	}

	public BookendRouteSegment findClosestEdge(final Coordinate coordinate){
		final LinearRing bb = BoundingBox.makeBoundingGeometryForPoint(geometryFactory, coordinate, .005);
		BookendRouteSegment closestEdge =  getHibernateTemplate().execute(new HibernateCallback<BookendRouteSegment>() {
			public BookendRouteSegment doInHibernate(Session session) throws HibernateException,
					SQLException {
				Query q = session.getNamedQuery("closestEdge");
				q.setParameter("coordinate", geometryFactory.createPoint(coordinate), geometryType);
				q.setParameter("boundingGeom", bb, geometryType);
				List<BookendRouteSegment> r = q.list();
				if(r != null && r.size() > 0){
					return r.get(0);
				}
				return null;
			}
		});
		return closestEdge;
	}

	public List<RouteSegment> findShortestPathRoute(BookendRouteSegment startEdge, 
			BookendRouteSegment endEdge, 
			Map<String,String> options){
		List<RouteSegment> segments = getHibernateTemplate().findByNamedQueryAndNamedParam("shortestPath", 
				new String[]{"source", "target"}, 
				new Object[]{new Integer(startEdge.getTarget()), new Integer(endEdge.getSource())});
		addBookendSegment(segments, startEdge, true);
		addBookendSegment(segments, endEdge, false);
		return segments;
	}

	private void addBookendSegment(List<RouteSegment> segments, 
			BookendRouteSegment segment, 
			boolean isStartEdge) {
		int index = isStartEdge ? 0 : (segments.size() - 1);
		RouteSegment rs = segments.get(index);
		if(segment.getSource() == rs.getSource() && segment.getTarget() == rs.getTarget()) {
			segments.remove(index);
		}
		if(isStartEdge) {
			segments.add(0, segment);
		} else {
			segments.add(segment);
		}
	}

	public void setGeometryFactory(GeometryFactory geometryFactory){
		this.geometryFactory = geometryFactory;
	}
}
