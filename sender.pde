//Sender Part 


#include <WaspXBee802.h>
#include <WaspSensorCities_PRO.h> // Library for using sensors in the Cities PRO suite.
#include <WaspFrame.h> // Library for creating and managing ASCII frames for sensor data.
//Instantiates a BME sensor object connected to socket A.
bmeCitiesSensor bme(SOCKET_A);

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

// node Id to be searched
char nodeToSearch[] = "node_RX";

// variable to store searched Destination 16-b Network Address
uint8_t networkAddress[2]; 

// define variable
uint8_t error;


void setup()
{
  // open USB port
  USB.ON();

  USB.println(F("-------------------------------"));
  USB.println(F("Configure XBee 802.15.4"));
  USB.println(F("-------------------------------"));

  // init XBee 
  xbee802.ON();


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

   // set NI (Node Identifier)
  xbee802.setNodeIdentifier("node_TX");  
  
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
  // 5. write values to XBee module memory
  /////////////////////////////////////
  xbee802.writeValues();

  // check the AT commmand execution flag
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
  // 1. Turn on the sensor
  ///////////////////////////////////////////

  bme.ON();

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
  USB.printHex(xbee802.PAN_ID[0]); 
  USB.printHex(xbee802.PAN_ID[1]); 
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

  //*************************************************TX*******************************/
  
  /////////////////////////////////////
  // 1. Search node 
  /////////////////////////////////////
  
  error = xbee802.nodeSearch( nodeToSearch, networkAddress);
 
  if( error == 0 )
  {
    USB.print(F("\nnaD:"));
    USB.printHex( networkAddress[0] );
    USB.printHex( networkAddress[1] );
    USB.println();
  }
  else 
  {
    USB.println(F("nodeSearch() did not find any node"));
  }
  
  
  /////////////////////////////////////  
  //  2. Send a packet to the searched node
  ////////////////////////////////////////

  if( error == 0 )
  {
    // convert network address from binary to ASCII
    char na_str[5];
    Utils.hex2str( networkAddress, na_str, 2);

       //2-1- Reads temperature, humidity, and pressure from the BME sensor.
              float temperature = bme.getTemperature();
              float humidity = bme.getHumidity();
              float pressure = bme.getPressure();

              //2-2  Print readings to USB for debugging
              USB.println(F("**********************************************"));
              USB.print(F("Temperature: "));
              USB.printFloat(temperature, 2);
              USB.println(F(" Celsius"));
              USB.print(F("Humidity: "));
              USB.printFloat(humidity, 2);
              USB.println(F(" %"));
              USB.print(F("Pressure: "));
              USB.printFloat(pressure, 2);
              USB.println(F(" Pa"));
              bme.OFF();

              //2-3 Create the ASCII frame
              frame.createFrame(ASCII);
              frame.addSensor(SENSOR_IN_TEMP, temperature);
              frame.addSensor(SENSOR_IN_TEMP, humidity);
              frame.addSensor(SENSOR_IN_TEMP, pressure);
             //2-4 prints frame 
              frame.showFrame();
             //2-5 Send frame 
              error = xbee802.send(na_str, frame.buffer, frame.length);
     

    // check TX flag
    if( error == 0 )
    {
      USB.println(F("Frame sent successfully"));

      // blink green LED
      Utils.blinkGreenLED();

    }
    else 
    {
      USB.println(F("Error sending frame"));
      // blink red LED
      Utils.blinkRedLED();  
    }
  }

  // wait   
  delay(3000);  
//**********************************************END:TX******************************
}



