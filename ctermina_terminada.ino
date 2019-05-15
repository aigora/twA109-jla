#include <Servo.h>
#include <Wire.h>
#include <Adafruit_MLX90614.h>

Adafruit_MLX90614 mlx = Adafruit_MLX90614();
enum Estados {INICIO, MEDIR, FIN};

Servo myservo;
Servo myservo1;
int fin_horizontal = 31;
int fin_vertical = 19;
Estados Estado;

int pos, pos1;

void setup() {
  Serial.begin(9600);
  myservo.attach(3);
  myservo1.attach(2);
  myservo.write(0);
  myservo1.write(16);
  // delay (100);
  // myservo.detach();
  //myservo1.detach();
  mlx.begin();
  Estado = INICIO;
}
void loop() {
  int tentero, tdecimal;
  float temperatura_real;
  //myservo.attach(13);
  //myservo1.attach(12);
  switch (Estado)
  {
    case INICIO: if (Serial.available() > 0)
        if ( Serial.read() == 1)
          Estado = MEDIR;
      break;
    case MEDIR:
      for (pos = 0; pos <= fin_horizontal; pos += 1)
      {
        myservo1.write(fin_horizontal - pos);
        for (pos1 = 0; pos1 <= fin_vertical; pos1 += 1)
        {
          myservo.write(pos1);
          delay(1000); //tiempo necesario          
          temperatura_real = mlx.readObjectTempC();
          tentero = (int) temperatura_real;
          tdecimal = (int) (temperatura_real * 100) - (tentero * 100);
          Serial.write(0);
          Serial.write(tentero);
          Serial.write(tdecimal);
          Serial.write(pos);
          Serial.write(pos1);          
        }
        delay(200);
      }
      Estado = FIN;
      break;

    case FIN:
      Serial.write(2);
      Serial.write(0);
      Serial.write(0);
      Serial.write(0);
      myservo.write(0);
      myservo1.write(0);
      //Estado = INICIO;
      break;
  }
}
