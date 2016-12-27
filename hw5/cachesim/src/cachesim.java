import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

public class cachesim {
	int myValid;
	String myTag;
	ArrayList<String> myData;
	
	
	/* CONSTRUCTOR
	 * CONSTRUCTOR
	 * CONSTRUCTOR
	 * CONSTRUCTOR
	 */
	public cachesim(int valid, String tag, ArrayList<String> data){
		this.myValid = valid; // valid of 5 means used 5 times ago
		this.myTag = tag;
		this.myData = data;
	}

	
	
	/* HELPER FCT
	 * HELPER FCT
	 * HELPER FCT
	 * HELPER FCT
	 */
	public static int getNumSets(int myCacheSize, int myAssoc, int myBlockSize){
		int numSets = (int) (myCacheSize * Math.pow(2, 10)/(myBlockSize * myAssoc));
		return numSets;
	}
	
	// "makeTable" depends on results from "getNumSets"
	public static cachesim[][] makeTable(int myAssoc, int numSets){
		cachesim[][] myTable = new cachesim[numSets][myAssoc];
		for(int i = 0; i < numSets; i++){
			for(int j = 0; j < myAssoc; j++){
				myTable[i][j] = new cachesim(0, null, null);
			}
		}
		return myTable;
	}
	
	public static String getBinary(String hexAddress){
		int addressInt = Integer.parseInt(hexAddress.substring(2), 16);
		String addressBin = String.format("%24s", Integer.toBinaryString(addressInt)).replace(' ', '0');
		return addressBin;
	}
		
	// "getOffset" depends on results from "getBinary"
	public static String getOffsetBits(String binAddress, int blockSize){
		int numOffset = (int) (Math.log(blockSize)/Math.log(2));
		int start = 24 - numOffset;
		String offsetBits = binAddress.substring(start);
		return offsetBits;
	}
	
	public static int getOffsetValue(String binAddress, int blockSize){
		String offsetBits = getOffsetBits(binAddress, blockSize);
		int offset = Integer.parseInt(offsetBits, 2);
		return offset;
	}
	
	// "getIndex" depends on results from "getOffset", "getBinary", and "getNumSets"
	public static String getIndexBits(String binAddress, int blockSize, int numSets){
		String offsetBits = getOffsetBits(binAddress, blockSize);
		int numOffset = offsetBits.length();
		int end = 24 - numOffset;
		
		int numIndexBits = (int) (Math.log(numSets)/Math.log(2));
		int start = end - numIndexBits;
		String indexBits = binAddress.substring(start,end);
		return indexBits;
	}
	
	public static int getSetValue(String binAddress, int blockSize, int numSets){
		String indexBits = getIndexBits(binAddress, blockSize, numSets);
		int setValue = 0;
		if (!indexBits.equals("")){
			setValue = Integer.parseInt(indexBits, 2);
		}
		return setValue;
	}
		
	// return tag bits, find set in decimal, offset in decimal
	public static String getTagBits(String binAddress, int blockSize, int numSets){
		String indexBits = getIndexBits(binAddress, blockSize, numSets);
		String offsetBits = getOffsetBits(binAddress, blockSize);
		int end = 24 - indexBits.length() - offsetBits.length();
		String tagBits = binAddress.substring(0, end);
		return tagBits;
	}
	
	// Which frame to place block
	public static int whereToPut(cachesim[][] myCacheTable, int myIndexValue, int assoc){
		int maxValid = 0;
		int maxValidIndex = 0;
		for(int i = 0; i < assoc; i++){
			cachesim myFrame = myCacheTable[myIndexValue][i];
			if((myFrame.myValid == 0) && (myFrame.myTag == null) && (myFrame.myData ==  null)){
				return i;
			}
			
			if(myFrame.myValid > maxValid){
				maxValid = myFrame.myValid;
				maxValidIndex = i;
			}
		}
		
		return maxValidIndex;
	}
	
	// Split data into bytes, store in Array List
	public static ArrayList<String> dataByteSize(String data){
		ArrayList<String> dataArray = new ArrayList<String>();
		int dataLength = data.length();
		for(int i = 0; i < dataLength; i = i + 2){
			String tempData = new StringBuilder().append(data.charAt(i)).append(data.charAt(i+1)).toString();
			dataArray.add(tempData);
		}
		
		return dataArray;
	}
	
	
	
	/* MAIN
	 * MAIN
	 * MAIN
	 * MAIN
	 */
	public static void main(String[] args) {
		// Get Command Line Arguments
		String fileName = args[0];
		int cacheSize = Integer.parseInt(args[1]);
		int assoc = Integer.parseInt(args[2]);
		int blockSize = Integer.parseInt(args[3]);
		
		
		// Start Reading File
		ArrayList<String> inputFileInstruction = new ArrayList<String>();
		
		try{
			FileReader fr = new FileReader(fileName);
			BufferedReader br = new BufferedReader(fr);
			String myStr;
			while((myStr = br.readLine()) != null){
				inputFileInstruction.add(myStr);
			}
			br.close();
		} catch(IOException e){
			System.err.println("Wrong File");
		}
		
		// Get Number of Sets
		int numSets = getNumSets(cacheSize, assoc, blockSize);
		
		// Create Cache Table, all valid value initialized as 0
		cachesim[][] myCacheTable = makeTable(assoc, numSets);
		
		// Main Memory
		// key: Tag plus index bits
		// value: Array list of Data
		HashMap<String, ArrayList<String>> myMemory = new HashMap<String, ArrayList<String>>();
		
		// Access Instructions
		for(String instr: inputFileInstruction){
			String[] instrArray = instr.split(" ");
			
			String loadStore = instrArray[0];
			
			// Addressing
			String myAddress = instrArray[1];
			String myBinAddress = getBinary(myAddress);	
			
			int accessSize = Integer.parseInt(instrArray[2]);

			int myOffsetValue = getOffsetValue(myBinAddress, blockSize);			// Offset Value (determines where in the block)			
			int myIndexValue = getSetValue(myBinAddress, blockSize, numSets);		// Index Value (determines which set)			
			String myTagBits = getTagBits(myBinAddress, blockSize, numSets);		// Tag bits
			String myTagPlusIndexBits = myTagBits + getIndexBits(myBinAddress, blockSize, numSets);
			
			String hitMiss = "miss";
			cachesim hitFrame = null;
			int hitIndexInCache = -1;
			
			for(int i = 0; i < assoc; i++){
				cachesim tempFrame = myCacheTable[myIndexValue][i];
				if((tempFrame.myTag != null) && (tempFrame.myTag.equals(myTagBits))){
					hitMiss = "hit";
					hitFrame = tempFrame;
					hitIndexInCache = i;
					break;
				}
			}
			
			
			if(loadStore.equals("load")){
				if(hitMiss.equals("hit")){
					ArrayList<String> tempData = hitFrame.myData;
					String outputData = "";
					for(int j = myOffsetValue; j < myOffsetValue + accessSize; j++){
						outputData += tempData.get(j);
					}
					System.out.println("load " + myAddress + " " + "hit " + outputData);
					continue;
				}
				
				// Add code for load miss
				if(hitMiss.equals("miss")){
					ArrayList<String> dataInMemory = null;
					if(myMemory.containsKey(myTagPlusIndexBits)){
						dataInMemory = myMemory.get(myTagPlusIndexBits);
					} else{
						ArrayList<String> listOfZeros = new ArrayList<String>();
						for(int k = 0; k < blockSize; k++){
							listOfZeros.add("00");
						}
						dataInMemory = listOfZeros;						
					}
					
					// print out data
					String outputData = "";
					for(int j = myOffsetValue; j < myOffsetValue + accessSize; j++){
						outputData += dataInMemory.get(j);
					}
					System.out.println("load " + myAddress + " " + "miss " + outputData);
					
					// Update LRU in myValid
					for(int m = 0; m < assoc; m++){
						if(myCacheTable[myIndexValue][m].myTag!=null){
							myCacheTable[myIndexValue][m].myValid += 1;
						}
					}
					
					// Evict block and add new block to frame
					int myTargetFrame = whereToPut(myCacheTable, myIndexValue, assoc);
					cachesim newFrame = new cachesim(0, myTagBits, dataInMemory);
					myCacheTable[myIndexValue][myTargetFrame] = newFrame;
									
				}
			}
			
			
			
			if(loadStore.equals("store")){
				String dataStore = instrArray[3];
				ArrayList<String> dataStoreList = dataByteSize(dataStore); // new data to be stored
				
				// Add code for store hit and miss
				if(hitMiss.equals("hit")){					
					ArrayList<String> currDataList = myCacheTable[myIndexValue][hitIndexInCache].myData; // old data currently in cache and main memory
					String[] currDataArray = currDataList.toArray(new String[currDataList.size()]); // convert old data to string array
					for(int n = 0; n < dataStoreList.size(); n++){
						currDataArray[n + myOffsetValue] = dataStoreList.get(n);
					}
					ArrayList<String> newDataList = new ArrayList<String>(Arrays.asList(currDataArray));
					myCacheTable[myIndexValue][hitIndexInCache].myData = newDataList;
					myMemory.put(myTagPlusIndexBits, newDataList);
					System.out.println("store " + myAddress + " hit");
				}
				
				if(hitMiss.equals("miss")){
					ArrayList<String> currDataList = null;
					if(myMemory.containsKey(myTagPlusIndexBits)){
						currDataList = myMemory.get(myTagPlusIndexBits); // old data currently in main memory
					} else{
						ArrayList<String> listOfZeros = new ArrayList<String>(); // list of zeros
						for(int k = 0; k < blockSize; k++){
							listOfZeros.add("00");
						}
						currDataList = listOfZeros;						
					}
					
					String[] currDataArray = currDataList.toArray(new String[currDataList.size()]); // convert old data to string array
					for(int n = 0; n < dataStoreList.size(); n++){
						currDataArray[n + myOffsetValue] = dataStoreList.get(n);
					}
					ArrayList<String> newDataList = new ArrayList<String>(Arrays.asList(currDataArray));
					myMemory.put(myTagPlusIndexBits, newDataList);
					System.out.println("store " + myAddress + " miss");
				}
					
			}
				
		}

	}

}
