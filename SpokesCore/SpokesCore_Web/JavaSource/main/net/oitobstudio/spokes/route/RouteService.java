package net.oitobstudio.spokes.route;

import org.springframework.dao.DataAccessException;
import org.springframework.transaction.annotation.Transactional;

import net.oitobstudio.spokes.SpokesException;

//@Transactional
public interface RouteService {
	//@Transactional(readOnly = true)
	public Route getShortestPathRoute(RouteCriteria routeCriteria) throws SpokesException, DataAccessException;
}
