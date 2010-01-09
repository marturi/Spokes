import java.io.FileReader;

import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.helpers.XMLReaderFactory;

public class KMLParser2 extends DefaultHandler {
	private String currentElement;
	private StringBuffer sql = new StringBuffer();
	private StringBuffer sb = new StringBuffer();
	
	public static void main (String args[]) throws Exception{
		XMLReader xr = XMLReaderFactory.createXMLReader();
		KMLParser2 handler = new KMLParser2();
		xr.setContentHandler(handler);
		xr.setErrorHandler(handler);

		for (int i = 0; i < args.length; i++) {
		    FileReader r = new FileReader(args[i]);
		    xr.parse(new InputSource(r));
		}
    }

	public void startDocument() {
	}

	public void endDocument() {
		System.out.print(sb.toString());
	}

	public void startElement(String uri, String name, String qName, Attributes atts) {
		currentElement = name;
	}

	public void endElement(String uri, String name, String qName) {
		if(currentElement.equals("description")){
			sb.append('\n');
		}
	}

	public void characters(char ch[], int start, int length) {
		if(currentElement.equals("description")){
			appendText(ch, start, length);
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
