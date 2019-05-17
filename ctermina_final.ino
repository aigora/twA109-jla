#include <Servo.h>
#include <Wire.h>
#include <Adafruit_MLX90614.h>

Adafruit_MLX90614 mlx = Adafruit_MLX90614();
enum Estados {INICIO, MEDIR, FIN}; // se enumeran los estados de la maquina

//se crean los objetos de clase servomotor
Servo myservo; 
Servo myservo1;
int fin_horizontal = 31;
int fin_vertical = 19;
Estados Estado;

int pos, pos1;

void setup() {
  Serial.begin(9600); // velocidad de comonucacion de datos por puerto serie
  myservo.attach(3); // pin en el que por el que se comunica la placa con el servomotor
  myservo1.attach(2);
  myservo.write(0); //posicion inicial para hacer la foto al objeto
  myservo1.write(16);  
  mlx.begin(); //comienza a funcionar el sensor de temperatura
  Estado = INICIO;
}
void loop() {
  int tentero, tdecimal;
  float temperatura_real; 
  switch (Estado)
  {
    case INICIO: if (Serial.available() > 0) // a la espara de recibir la señal del ordenador para empezar
        if ( Serial.read() == 1)             // comprobacion de la señal recibida sea la correcta 
         myservo.write(0); //desplaza a la posicion inicial para empezar a funcionar
         myservo1.write(0);
          Estado = MEDIR;
      break;
    case MEDIR:
      for (pos = 0; pos <= fin_horizontal; pos += 1) //empieza el procedimiento de escaneo de objeto y toma de medidas
      {
        myservo1.write(fin_horizontal - pos);
        for (pos1 = 0; pos1 <= fin_vertical; pos1 += 1)
        {
          myservo.write(pos1);
          delay(1000); //tiempo necesario para una buena realizacion de la medicion de temperatura         
          temperatura_real = mlx.readObjectTempC(); // el valor de temperatura dado por el sensor es de tipo float, que no puede ser enviado en este formato
          tentero = (int) temperatura_real;  // se procesa el valor y se manda en dos paquetes de datos por puerto serie
          tdecimal = (int) (temperatura_real * 100) - (tentero * 100); 
          Serial.write(0); //envio de señal de cotrol
          Serial.write(tentero); //envio de valor temperatura
          Serial.write(tdecimal);
          Serial.write(pos); //se mandan las coordenadas del punto del que se ha tomado la temperatura
          Serial.write(pos1);          
        }
        delay(200);
      }
      Estado = FIN;
      break;

    case FIN:
      Serial.write(2);// se envia la señal de que el proceso ha terminado
      Serial.write(0);
      Serial.write(0);
      Serial.write(0);
      myservo.write(0);
      myservo1.write(0);
      Estado = INICIO; // se reinicia el proceso para un nuevo escaneo
      break;
  }
}
