/* DIGF 6037 Creation & Computation
 * Kate Hartman & Nick Puckett
 * 
 * 
 * This example gets stable Pitch and Roll angles from the internal IMU
 * on the Arduino Nano33 IOT using a complimentary filter
 * 
 * Interface via the Sparkfun LSM6DS3 library: https://github.com/sparkfun/SparkFun_LSM6DS3_Arduino_Library
 * Filter Code by Trent Cleghorm: https://github.com/tcleg/Six_Axis_Complementary_Filter
 * 
 * This example sends these values to processing in a comma separated protocol
 */



#include "SparkFunLSM6DS3.h"
#include "Wire.h"
#include "six_axis_comp_filter.h"


LSM6DS3 nano33IMU(I2C_MODE, 0x6A); //define the IMU object
CompSixAxis CompFilter(0.1, 2); //define the filter object


float pitch;
float roll;


void setup() 
{
  Serial.begin(9600);
  
  //Call .begin() to configure the IMU (Inertial Measurement Unit)
  nano33IMU.begin();
}


void loop() 
{
calculatePitchAndRoll();
}


void calculatePitchAndRoll()
{
  float accelX, accelY, accelZ, // variables to store sensor values
      gyroX, gyroY, gyroZ,
      xAngle, yAngle;       

  //  Get all motion sensor (in this case LSM6DS3) parameters,
  //  If you're using a different sensor you'll have to replace the values
  accelX = nano33IMU.readFloatAccelX();
  accelY = nano33IMU.readFloatAccelY();
  accelZ = nano33IMU.readFloatAccelZ();

  gyroX = nano33IMU.readFloatGyroX();
  gyroY = nano33IMU.readFloatGyroY();
  gyroZ = nano33IMU.readFloatGyroZ();

  // Convert these values into angles using the Complementary Filter
  CompFilter.CompAccelUpdate(accelX, accelY, accelZ); // takes arguments in m/s^2
  CompFilter.CompGyroUpdate(gyroX, gyroY, gyroZ); // takes arguments un rad/s 
  CompFilter.CompUpdate();
  CompFilter.CompStart();

  // Get angle relative to X and Y axes and write them to the variables in the arguments
  //in radians
  CompFilter.CompAnglesGet(&xAngle, &yAngle);

  //convert from radians to angles
  pitch = xAngle*RAD_TO_DEG;
  roll = yAngle*RAD_TO_DEG;

  
  Serial.print(pitch);
  Serial.print(",");
  Serial.println(roll);

  //this is need for stability of the connection
  delay(100);
}
