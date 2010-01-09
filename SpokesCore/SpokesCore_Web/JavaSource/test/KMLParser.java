import java.io.FileReader;

import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.helpers.XMLReaderFactory;

public class KMLParser extends DefaultHandler {
	private String currentElement;
	private boolean process = false;
	private StringBuffer sql = new StringBuffer();
	private StringBuffer sb = new StringBuffer();
	
	public static void main (String args[]) throws Exception{
		XMLReader xr = XMLReaderFactory.createXMLReader();
		KMLParser handler = new KMLParser();
		xr.setContentHandler(handler);
		xr.setErrorHandler(handler);

		//for (int i = 0; i < args.length; i++) {
		    FileReader r = new FileReader("/users/marturi/Desktop/bike_shops1.xml");
		    xr.parse(new InputSource(r));
		//}
    }

	public void startDocument() {
	}

	public void endDocument() {
		System.out.print(sql.toString());
	}

	public void startElement(String uri, String name, String qName, Attributes atts) {
		currentElement = name;
		if(currentElement.equals("Placemark")){
			sql.append("insert into nyc_bike_shops (shop_name,street,phone,wkb_geometry,borough) values(");
			process = true;
		}
		if(process){
			if(currentElement.equals("name")){
				sql.append("'");
			}
			else if(currentElement.equals("Snippet")){
				sql.append("'");
			}
			else if(currentElement.equals("coordinates")){
				sql.append("((SELECT SETSRID(ST_MakePoint(");
			}
		}
	}

	public void endElement(String uri, String name, String qName) {
		currentElement = name;
		if(currentElement.equals("Placemark")){
			process = false;
			sql.append(",'Staten Island');\n");
		}
		if(process){
			String street = null;
			String phone = null;
			String coordinates = null;
			if(currentElement.equals("name")){
				String newStr = sb.toString().replaceAll("'", "''");
				sql.append(newStr);
				sql.append("',");
			}
			else if(currentElement.equals("Snippet")){
				street = sb.substring(0,sb.indexOf("<"));
				phone = sb.substring(sb.indexOf(">")+1);
				//System.out.println(street);
				sql.append(street).append("',");
				sql.append("'").append(phone).append("',");
			}
			else if(currentElement.equals("coordinates")){
				if(sb.indexOf(",0") > -1){
					coordinates = sb.substring(0, sb.indexOf(",0"));
				}
				if(coordinates != null){
					sql.append(coordinates).append("),4326)))");
				}
			}
			sb.delete(0, sb.length());
		}
	}

	public void characters(char ch[], int start, int length) {
		if(process){
			if(currentElement.equals("name")){
				appendText(ch, start, length);
			}
			else if(currentElement.equals("Snippet")){
				appendText(ch, start, length);
			}
			else if(currentElement.equals("coordinates")){
				appendText(ch, start, length);
			}
		}
	}

	private void appendText(char ch[], int start, int length){
		for (int i = start; i < start + length; i++) {
			switch (ch[i]) {
			case '\n':
				break;
			case '\r':
				break;
			case '\t':
				break;
			default:
				sb.append(ch[i]);
				break;
			}
		}
	}
}
