package net.oitobstudio.spokes.proxy;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;

public class SpokesProxyFilter implements Filter {
	
	public void destroy() {}

	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
		throws IOException, ServletException {
		String url = ((HttpServletRequest)request).getRequestURL().toString();
		ServletContext foreignContext = ((HttpServletRequest)request).getSession().getServletContext().getContext("/SpokesNYC_Web");
		if(foreignContext != null) {
			String fwdAddress = url.substring(url.indexOf("/icycle"));
			RequestDispatcher rd = foreignContext.getRequestDispatcher(fwdAddress);
			if(rd != null) {
				rd.forward(request, response);
			}
		}
	}

	public void init(FilterConfig filterConfig) throws ServletException {
	}
}