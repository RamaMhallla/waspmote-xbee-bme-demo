//Receiver Part 
#include <WaspXBee802.h>

// PAN (Personal Area Network) Identifier
uint8_t  panID[2] = {0x12,0x34}; 

// Define Freq Channel to be set: 
// Center Frequency = 2.405 + (CH - 11d) * 5 MHz
//   Range: 0x0B - 0x1A (XBee)
//   Range: 0x0C - 0x17 (XBee-PRO)
uint8_t  channel = 0x0F;

// Define the Encryption mode: 1 (enabled) or 0 (disabled)
uint8_t encryptionMode = 0;

// Define the AES 16-byte Encryption Key
char  encryptionKey[] = "WaspmoteLinkKey!"; 

// node ID
char nodeID[] = "node_RX";

// define variable
uint8_t error;

// Arrays to store temperature, humidity, and pressure values
float temperatureValues[10];
float humidityValues[10];
float pressureValues[10];
uint8_t packetCount = 0;// Packet counter to track received data


void setup()
{
  // open USB port
  USB.ON();

  USB.println(F("-------------------------------"));
  USB.println(F("Configure XBee 802.15.4"));
  USB.println(F("-------------------------------"));

  // init XBee 
  xbee802.ON();
    // 1.2. set NI (Node Identifier)
  xbee802.setNodeIdentifier( nodeID );
  
  // check at commmand execution flag
  if( xbee802.error_AT == 0 ) 
  {
    USB.println(F("Node ID set OK"));
  }
  else 
  {
    USB.println(F("Error setting Node ID"));
  }


  /////////////////////////////////////
  // 1. set channel 
  /////////////////////////////////////
  xbee802.setChannel( channel );

  // check at commmand execution flag
  if( xbee802.error_AT == 0 ) 
  {
    USB.print(F("1. Channel set OK to: 0x"));
    USB.printHex( xbee802.channel );
    USB.println();
  }
  else 
  {
    USB.println(F("1. Error calling 'setChannel()'"));
  }


  /////////////////////////////////////
  // 2. set PANID
  /////////////////////////////////////
  xbee802.setPAN( panID );

  // check the AT commmand execution flag
  if( xbee802.error_AT == 0 ) 
  {
    USB.print(F("2. PAN ID set OK to: 0x"));
    USB.printHex( xbee802.PAN_ID[0] ); 
    USB.printHex( xbee802.PAN_ID[1] ); 
    USB.println();
  }
  else 
  {
    USB.println(F("2. Error calling 'setPAN()'"));  
  }

  /////////////////////////////////////
  // 3. set encryption mode (1:enable; 0:disable)
  /////////////////////////////////////
  xbee802.setEncryptionMode( encryptionMode );

  // check the AT commmand execution flag
  if( xbee802.error_AT == 0 ) 
  {
    USB.print(F("3. AES encryption configured (1:enabled; 0:disabled):"));
    USB.println( xbee802.encryptMode, DEC );
  }
  else 
  {
    USB.println(F("3. Error calling 'setEncryptionMode()'"));
  }

  /////////////////////////////////////
  // 4. set encryption key
  /////////////////////////////////////
  xbee802.setLinkKey( encryptionKey );

  // check the AT commmand execution flag
  if( xbee802.error_AT == 0 ) 
  {
    USB.println(F("4. AES encryption key set OK"));
  }
  else 
  {
    USB.println(F("4. Error calling 'setLinkKey()'")); 
  }

  /////////////////////////////////////
  // 5. write values to XBee module memory
  /////////////////////////////////////
  xbee802.writeValues();

  // check the AT commmand execution flag
  // Check if the configuration was stored successfully
  if( xbee802.error_AT == 0 ) 
  {
    USB.println(F("5. Changes stored OK"));
  }
  else 
  {
    USB.println(F("5. Error calling 'writeValues()'"));   
  }

  USB.println(F("-------------------------------")); 
}



void loop()
{
//*******************Configuration **********************************************************//
  /////////////////////////////////////
  // 1. get channel 
  /////////////////////////////////////
  xbee802.getChannel();
  USB.print(F("channel: "));
  USB.printHex(xbee802.channel);
  USB.println();

  /////////////////////////////////////
  // 2. get PANID
  /////////////////////////////////////
  xbee802.getPAN();
  USB.print(F("panid: "));
  USB.printHex(xbee802.PAN_ID[0]); // Print the first byte of the PAN ID
  USB.printHex(xbee802.PAN_ID[1]); // Print the second byte of the PAN ID
  USB.println(); 

  /////////////////////////////////////
  // 3. get encryption mode (1:enable; 0:disable)
  /////////////////////////////////////
  xbee802.getEncryptionMode();
  USB.print(F("encryption mode: "));
  USB.printHex(xbee802.encryptMode);
  USB.println(); 

  USB.println(F("-------------------------------")); 

  delay(3000);
  //*******************END:Configuration **********************************************************//

  //*******************STAET:RX **********************************************************//
  //For  loop runs three times to handle three values sequentially.  
  
   for (int i = 0; i <10; i++) {
    // receive XBee packet (wait for 10 seconds)
    //A method from the XBee library that attempts to receive a packet
        error = xbee802.receivePacketTimeout( 10000 );
        
          // check answer  
          if( error == 0 ) 
          {
              USB.print ("i=");
              USB.println (i);
            // Show data stored in '_payload' buffer indicated by '_length'
            USB.print(F("Data: "));  
            USB.println( xbee802._payload, xbee802._length);// Print the received data
            ExtractData(xbee802._payload, xbee802._length);// Extract and process sensor values
          }
          else
          {
            USB.print ("i=");
              USB.println (i);
          
            USB.print(F("Error receiving a packet:"));
            USB.println(error,DEC); // Print the error code    
          }
  
   }
     
   

}
  
  //*******************END:RX**********************************************************//

  
//funxtion to extract data 
// try to print the frame then think how can we extract each value from it (Remember offset )
            //Data: <=>€#356904982#node_01#71#IN_TEMP:23.67#IN_TEMP:42.91#IN_TEMP:98820.40#
             //Header: <=>€# → 6 characters
            //ID: 356904982# → 10 characters
            //Node: node_01# → 8 characters
            //Sequence: 71# → 3 characters
            //First IN_TEMP:
            //Label: IN_TEMP: → 8 characters
            //Value: 23.67# → 6 characters

void ExtractData(uint8_t* payload, int length) {
            if (xbee802._length > 0) {
                    // Extract temperature, humidity, and pressure from payload
                    float test= atof((char*)xbee802._payload+ 29);
                     USB.printFloat(test,2  );
                     USB.println("");
                    float temp1= atof((char*)xbee802._payload+36);
                    float humd1= atof((char*)xbee802._payload+ 50);
                    float pressure1= atof((char*)xbee802._payload+ 64);

                     // Print extracted values
                    USB.print(F("TMP: "));
                    USB.printFloat(temp1,2);
                    USB.println(F(" Celsius degrees"));
                   
                    USB.print(F("RH: "));
                    USB.printFloat(humd1, 2);
                    USB.println(F(" %"));
                    
                    USB.print(F("Pressure: "));
                    USB.printFloat(pressure1, 2);
                    USB.println(F(" Pa"));

                // Store the sensor values
                if (packetCount < 10) {
                  temperatureValues[packetCount] = temp1;
                  humidityValues[packetCount] = humd1;
                  pressureValues[packetCount] = pressure1;
                  packetCount++;


                                 
                }
            
                // If 10 packets are received, process the data
                if (packetCount == 10) {
                  sortValues(temperatureValues); // Sort temperature values
                  sortValues(humidityValues);    // Sort humidity values
                  sortValues(pressureValues);    // Sort pressure values

                  float medianTemp = calculateMedian(temperatureValues); // Calculate median temperature
                  float medianHum = calculateMedian(humidityValues);     // Calculate median humidity
                  float medianPress = calculateMedian(pressureValues);   // Calculate median pressure

                  USB.println(F("\nMedian Values for Last 10 Frames:"));
                  USB.print(F("Median Temp: "));
                  USB.printFloat(medianTemp, 2);
                  USB.println(F(" °C"));
                  USB.print(F("Median Hum: "));
                  USB.printFloat(medianHum, 2);
                  USB.println(F(" %"));
                  USB.print(F("Median Press: "));
                  USB.printFloat(medianPress, 2);
                  USB.println(F(" Pa"));
                  
                  printAverages();
                  packetCount = 0; // Reset packet count for next batch
                }
            }
         }
  
//Function To Calculate The Averages 
// Function to calculate and print averages of temperature, humidity, and pressure
void printAverages() {
    float sumTemp = 0, sumHum = 0, sumPress = 0;
    int validFrames = 0;

    USB.println(F("\nCollected Values for Last 10 Frames:"));
    
    for (int i = 0; i < 10; i++) {
      // Check for valid data
        if (temperatureValues[i] != 0 || humidityValues[i] != 0 || pressureValues[i] != 0) {
            USB.print(F("Frame "));
            USB.print(i + 1);
            USB.print(F(": Temp = "));
            USB.printFloat(temperatureValues[i], 2);
            USB.print(F("Celsius degrees, Hum = "));
            USB.printFloat(humidityValues[i], 2);
            USB.print(F(" %, Press = "));
            USB.printFloat(pressureValues[i], 2);
            USB.println(F(" Pa"));

            sumTemp += temperatureValues[i];
            sumHum += humidityValues[i];
            sumPress += pressureValues[i];

            validFrames++; // Count frames with valid data
        }
    }//end for

    // Calculate averages
    float avgTemp = validFrames > 0 ? sumTemp / validFrames : 0;
    float avgHum = validFrames > 0 ? sumHum / validFrames : 0;
    float avgPress = validFrames > 0 ? sumPress / validFrames : 0;

    USB.println(F("\nAverages for Last 10 Frames:"));
    USB.print(F("Average Temp: "));
    USB.printFloat(avgTemp, 2);
    USB.println(F(" Celsius degrees"));
    USB.print(F("Average Hum: "));
    USB.printFloat(avgHum, 2);
    USB.println(F(" %"));
    USB.print(F("Average Press: "));
    USB.printFloat(avgPress, 2);
    USB.println(F(" Pa"));
}

// Function to sort an array of 10 values in ascending order
void sortValues(float* values) {
  
  USB.println(F("\nArray before sorting:"));
  for (int i = 0; i < 10; i++) {
    USB.printFloat(values[i], 2);
    USB.print(F(" "));
  }
  USB.println();

  
  for (int i = 0; i < 9; i++) {
    for (int j = i + 1; j < 10; j++) {
      if (values[i] > values[j]) {
        float temp = values[i];
        values[i] = values[j];
        values[j] = temp;
      }
    }
  }

  
  USB.println(F("Array after sorting:"));
  for (int i = 0; i < 10; i++) {
    USB.printFloat(values[i], 2);
    USB.print(F(" "));
  }
  USB.println();
}

// Function to calculate the median of an array of 10 sorted values
float calculateMedian(float* values) {
  // For 10 values, the median is the average of the 5th and 6th values (0-based index: 4 and 5)
  return (values[4] + values[5]) / 2.0;
}
