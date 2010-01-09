import java.io.FileInputStream;
import java.nio.channels.FileChannel;
import java.nio.charset.Charset;
import java.nio.ByteBuffer;
import java.util.regex.*;

public class CoordinateExtractor {
	public static void main(String[] args) throws Exception{
		FileInputStream fstream = new FileInputStream("/Users/marturi/Desktop/shelter.kml");
		FileChannel fc = fstream.getChannel();
		ByteBuffer bbuf = fc.map(FileChannel.MapMode.READ_ONLY, 0, (int)fc.size());
        CharSequence cbuf = Charset.forName("8859_1").newDecoder().decode(bbuf);
        Pattern pattern = Pattern.compile("<coordinates[^>]*>(.*?)</coordinates>");
        Matcher matcher = pattern.matcher(cbuf);
    
        // Find all matches
        int i = 0;
        while (matcher.find()) {
            // Get the matching string
            String match = matcher.group();
            System.out.println(match);
            i++;
        }
        System.out.println(i);
	}
}
