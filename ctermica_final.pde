import processing.serial.*;

import processing.video.*;
/*
  Declaro estados de la maquina
 */

abstract class Estados 
{
  static final int INICIO = 0;
  static final int RECIBIR = 1;
  static final int GUARDAR = 2;
}
int estado = Estados.INICIO; // inicializo la maquina a INICIO
/*
  Inicializo la camara
 */
Capture cam;
/*
  Creo estructura botones
 */
class CBoton
{
  int xpos, ypos, ancho, alto, fondo;
  String etiqueta;
  CBoton (int x, int y, int a, int h, int c, String e)
  {
    xpos = x;
    ypos = y;
    ancho = a;
    alto = h;
    fondo = c;
    etiqueta = e;
  }
  void show ()
  {
    fill (fondo);
    rect (xpos, ypos, ancho, alto, 7);
    textSize(16);
    fill(255);
    textAlign(CENTER, CENTER);
    text(etiqueta, xpos, ypos, ancho, alto);
    stroke(0);
  }
  void unshow ()
  {
    stroke(255);
    fill (255);
    rect (xpos, ypos, ancho, alto);
  }
  int buttonClick(int x, int y)
  {
    int resultado;
    if (x>=xpos && x<=xpos+ancho && y>=ypos && y<=ypos+alto)
      resultado = 1;
    else
      resultado = 0;
    return resultado;
  }
}

/*
  Inicializo los  botones
 */

CBoton BIniciar; // Botón Iniciar
CBoton BGuardar; // Botón Guardar
CBoton BReiniciar; //Boton Reiniciar

/*
  Creo las particiones
 */
class Particion //Mitad izquierda de la pantalla en la que estara la imagen de la camara web
{
  int xpos, ypos, ancho, alto, fondo;
  Particion (int x, int y, int a, int h, int c)
  {
    xpos = x;
    ypos = y;
    ancho = a;
    alto = h;
    fondo = c;
  }
  void unshow()
  {
    stroke(255);
    fill (255);
    rect (xpos, ypos, ancho, alto);
  }
  void show ()
  {

    stroke(0);
    fill (fondo);
    rect (xpos, ypos, ancho, alto);
    noStroke();
    image(cam, xpos, ypos); // se crea la imagen tomada por la webcam, se se dibuja en el punto (0,0)
  }
}
class Colores //Mitad derecha de la pantalla donde estara un diagrama con colores en la que se indicara que puntos estan mas calientes que otros
{
  int xpos, ypos, ancho, alto, fondo;
  Table Puntos;
  Colores (int x1, int y1, int a, int h, int c)
  {
    xpos = x1;
    ypos = y1;
    ancho = a;
    alto = h;
    fondo = c;   
    Puntos = new Table();
    Puntos.addColumn("x");
    Puntos.addColumn("y");
    Puntos.addColumn("Temperatura");
  }
  void unshow()
  {
    stroke(255);
    fill (255);
    rect (xpos, ypos, ancho, alto);
  }
  void show ()
  {    
    stroke(0);
    fill (fondo);
    rect (xpos, ypos, ancho, alto);
    noStroke();
  }
  void almacena(int x, int y, float temp) //funcion en la que se almacenan los datos recibidos por arduino para su interpretacion
  {
    TableRow medida = Puntos.addRow();
    medida.setInt("x", x);
    medida.setInt("y", y);
    medida.setFloat("Temperatura", temp);
    dibuja(x, y, temp);
  }
  void dibuja(int x, int y, float temp) //funcion en la que se da un color al punto escaneado, de coordenadas (x,y), en funcion del valor recibido por el arduino
  {
    int xdibujo, ydibujo, ancho, alto;
    ancho = 20;
    alto = 24;
    xdibujo = (x*ancho)+640; // lo multiplico por el alto y por el ancho para adaptar la pantalla de los colores al escaneo de los servos.
    ydibujo = y*alto;        // para asi dibujar cada punto donde le corresponde

    if (temp >35.00)  // en funcion del valor de temperatura este algoritmo nos dice de que color representarlo
    {
      rect(xdibujo, ydibujo, ancho, alto);
      fill(128, 0, 0);//Rojo intenso
      noStroke();
    } else
    {
      if (temp>31.00)
      { 
        rect(xdibujo, ydibujo, ancho, alto);
        fill(255, 0, 0);//Rojo medio
        noStroke();
      } else
      {
        if (temp>29.50)
        {
          rect(xdibujo, ydibujo, ancho, alto);
          fill(178, 34, 34);//Rojo
          noStroke();
        } else {
          if (temp>28.00)
          {
            rect(xdibujo, ydibujo, ancho, alto);
            fill(255, 69, 0);//Naranja intenso
            noStroke();
          } else {
            if (temp>27.50) {

              rect(xdibujo, ydibujo, ancho, alto);
              fill(255, 140, 0);//naranja medio
              noStroke();
            } else { 
              if (temp>27.00) {

                rect(xdibujo, ydibujo, ancho, alto);
                fill(255, 255, 0);//naranja
                noStroke();
              } else {
                if (temp>26.50) {

                  rect(xdibujo, ydibujo, ancho, alto);
                  fill(135, 206, 250);//Azul claro
                  noStroke();
                } else {
                  if (temp>26.00) {

                    rect(xdibujo, ydibujo, ancho, alto);
                    fill(0, 191, 255);//Azul medio
                    noStroke();
                  } else {

                    rect(xdibujo, ydibujo, ancho, alto);
                    fill(0, 0, 139);//Azul intenso
                    noStroke();
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}


/*
  Inicializo las particiones
 */

Particion foto;
Colores imgtermica;

/*
  Defino la clase de comunicacion serie
 */
class CSerie
{
  Serial puerto;
  CSerie (Serial p)
  {
    puerto= p;
  }
  void Start ()
  {
    puerto.write(1); //cuando se llama a la funcion CanalSerie.start() esta manda un 1a traves de puerto serie al arduino, señal de que debe empezar con el escaneo
  }
  int available()
  {
    return puerto.available(); //datos disponibles en el buffer del puerto serie
  }
  int leerMedida()
  {
    return puerto.read(); // Se lee un dato del buffer puerto serie
  }
}
CSerie CanalSerie; // Comunicación serie con Arduino
Serial myPort;

/*
  Ejecución
 */

void setup()
{
  size(1280, 580); //creo la ventana (ancho,alto)
  if ( frame != null ) { 
    frame.setResizable(true);
  }
  background (255); 
  String portName = Serial.list()[0]; 
  myPort = new Serial(this, portName, 9600); // se crea la comunicacion porpuerto serie con el arduino
  CanalSerie = new CSerie(myPort); 

  BIniciar = new CBoton (600, 520, 80, 30, 127, "Iniciar"); // Crea el botón Iniciar
  BGuardar = new CBoton (300, 520, 80, 30, 127, "Guardar"); // Crea el botón Guardar
  BReiniciar = new CBoton (900, 520, 80, 30, 127, "Reiniciar"); // Crea el botón Reiniciar
  foto = new Particion(0, 0, 640, 480, 255); //Crea la particion de la imagen webcam
  imgtermica = new Colores(640, 0, 640, 480, 255); //crea la pantalla en blanco donde se va a dibujar el diagrama
  String[] cameras = Capture.list(); //se enumera las camaras disponibles para ser utilizada por el ordenador

  if (cameras.length == 0) 
  {
    println("No hay camaras disponibles.");
    exit();
  } else 
  {
    println("Camaras disponibles.");
    for (int i = 0; i < cameras.length; i++) 
    {
      println(cameras[i]);
    }
    cam = new Capture(this, cameras[13]); //elegimos la camara que queremos y creamos el objeto para que sea utilizado por el programa
    cam.start(); //la camara empieza a funcionar
  }
}
/*
  Creo la funcion de la camara web
 */

void draw()
{
  int status, x, y, tentero, tdecimal;
  float temp;
  if (cam.available() == true) 
  {
    cam.read(); //la camara hace una foto 
  }
  switch (estado)
  {
  case Estados.INICIO: 
    BIniciar.show();
    break;
  case Estados.RECIBIR:
    if (CanalSerie.available() > 4) // espera hasta que en el buffer haya 5 datos y los lee
    {
      status = CanalSerie.leerMedida();
      print ("Estado "+status);
      tentero = CanalSerie.leerMedida(); //procesamiento para volver a crear el valor de temperatura en formato real
      tdecimal = CanalSerie.leerMedida();
      temp = tentero + (float) tdecimal/100;
      print ("Temperatura ", temp);
      x = CanalSerie.leerMedida() ;
      y = CanalSerie.leerMedida() ; 
      print (" (X,Y)=", x, ",", y);

      if (status == 2)
        estado = Estados.GUARDAR; //Cuando lee la señal de que ha terminado con el proceso pasa al siguiente estado 
      else
        imgtermica.almacena(x, y, temp); //mientras que no se de la señal de finalizar, coge esos datos y los interpreta
    }

    break;

  case Estados.GUARDAR: 
    BGuardar.show();
    BReiniciar.show();
    break;
  }
}
// Gestor eventos del ratón sensible a estados de la aplicacion
void mouseClicked()
{
  switch (estado)
  {
  case Estados.INICIO: 
    if (BIniciar.buttonClick(mouseX, mouseY)== 1)
      transicion_Inicio_Recibir();
    break;
  case Estados.GUARDAR: 
    if (BReiniciar.buttonClick(mouseX, mouseY) == 1)
      transicion_Guardar_Inicio();
    else
      if (BGuardar.buttonClick(mouseX, mouseY) == 1);
    transicion_Guardar_Guardar();
    break;
  }
}
// Transiciones entre estados
void transicion_Inicio_Recibir()
{
  BIniciar.unshow();
  CanalSerie.Start(); // se envia la señal a arduino para que comienze a funcionar
  foto.show();
  imgtermica.show();
  estado = Estados.RECIBIR;
}
void transicion_Guardar_Inicio()
{
  BGuardar.unshow();
  BReiniciar.unshow();
  foto.unshow();
  imgtermica.unshow();
  BIniciar.show();
  estado = Estados.INICIO;
}
void transicion_Guardar_Guardar()
{
  // Almacena la imagen en un fichero externo
  // Se crea con laintencion de implementar en el futuro elmecanismo para guardar en el ordenador, el trabajo realizado por la camara termica
}
