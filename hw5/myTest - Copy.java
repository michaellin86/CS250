package cachesim;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;

public class myTest {
	
	
		int myValid;
		String myTag;
		ArrayList<String> myData;
		
		
		/* CONSTRUCTOR
		 * CONSTRUCTOR
		 * CONSTRUCTOR
		 * CONSTRUCTOR
		 */
		public myTest(int valid, String tag, ArrayList<String> data){
			this.myValid = valid; // valid of 5 means used 5 times ago
			this.myTag = tag;
			this.myData = data;
		}

	
	public static String getBinary(String myAddress){
		int addressInt = Integer.parseInt(myAddress, 16);
		String addressBin = String.format("%24s", Integer.toBinaryString(addressInt)).replace(' ', '0');
		return addressBin;
	}
	
	public static ArrayList<String> dataByteSize(String data){
		ArrayList<String> dataArray = new ArrayList<String>();
		int dataLength = data.length();
		for(int i = 0; i < dataLength; i = i + 2){
			String tempData = new StringBuilder().append(data.charAt(i)).append(data.charAt(i+1)).toString();
			dataArray.add(tempData);
		}
		
		return dataArray;
	}
	
	
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		String hex = "1a25bb";
		String bin = getBinary(hex);
//		System.out.println(bin);
		String indexBits = "0001010";
		int setValue = Integer.parseInt(indexBits, 2);
		System.out.println(setValue);
		
		int [] blah = new int [5];
		System.out.println(blah[1] + 1);
		
		String[] currDataArray = dataByteSize("7d2f13ac").toArray(new String[dataByteSize("7d2f13ac").size()]);
		System.out.println(currDataArray);
		for(String s: currDataArray){
			System.out.println(s);
		}
		ArrayList<String> newDataList = new ArrayList<String>(Arrays.asList(currDataArray));
		System.out.println(newDataList);
		
		
		
	}

}

