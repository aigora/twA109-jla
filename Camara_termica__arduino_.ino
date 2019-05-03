#include <Servo.h>
#include <Wire.h>
#include <Adafruit_MLX90614.h>

Adafruit_MLX90614 mlx = Adafruit_MLX90614();
int i;

Servo myservo;// crea el objeto servo
Servo myservo1;
int pos = 0,pos1;
int temperaturas[91][91];

void setup() {
  Serial.begin(9600);
  myservo.attach(13);// vincula el servo al pin digital 9
  myservo1.attach(12);
  myservo.write(0);
  myservo1.write(0);
  mlx.begin();
}

void loop() {
  for (pos = 0; pos <= 90; pos += 1)
  {
    myservo.write(pos);
   for(pos1=0;pos1<=120;pos1+=1)
   {
       myservo1.write(pos1);
       datos[i][j]=mlx.readObjectTempC();
       delay(15);
       }   
    delay(100);
  }
}
