import processing.serial.*;

import processing.video.*;
/*
  Declaro estados
 */

abstract class Estados //estados para la maquina
{
  static final int INICIO = 0;
  static final int RECIBIR = 1;
  static final int GUARDAR = 2;
}
int estado = Estados.INICIO;
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
CBoton BReiniciar;

/*
  Creo las particiones
 */
class Particion
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
    image(cam, xpos, ypos);
  }
}
class Colores
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
  void almacena(int x, int y, float temp)
  {
    TableRow medida = Puntos.addRow();
    medida.setInt("x", x);
    medida.setInt("y", y);
    medida.setFloat("Temperatura", temp);
    dibuja(x, y, temp);
  }
  void dibuja(int x, int y, float temp)
  {
    int xdibujo, ydibujo, ancho, alto;
    ancho = 20;
    alto = 24;
    xdibujo = (x*ancho)+640; // lo multiplico por el alto y por el ancho para adaptar la pantalla de los colores al escaneo de los servos.
    ydibujo = y*alto;

    if (temp >35.00)
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
  Defino la funcion de comunicacion serie
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
    puerto.write(1);
  }
  int available()
  {
    return puerto.available();
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
  myPort = new Serial(this, portName, 9600); 
  CanalSerie = new CSerie(myPort); 

  BIniciar = new CBoton (600, 520, 80, 30, 127, "Iniciar"); // Crea el botón Iniciar
  BGuardar = new CBoton (300, 520, 80, 30, 127, "Guardar"); // Crea el botón Guardar
  BReiniciar = new CBoton (900, 520, 80, 30, 127, "Reiniciar"); // Crea el botón Reiniciar
  foto = new Particion(0, 0, 640, 480, 255);
  imgtermica = new Colores(640, 0, 640, 480, 255);
  String[] cameras = Capture.list();

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
    cam = new Capture(this, cameras[13]);
    cam.start();
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
    cam.read();
  }
  switch (estado)
  {
  case Estados.INICIO: 
    BIniciar.show();
    break;
  case Estados.RECIBIR:
    if (CanalSerie.available() > 4)
    {
      status = CanalSerie.leerMedida();
      print ("Estado "+status);
      tentero = CanalSerie.leerMedida();
      tdecimal = CanalSerie.leerMedida();
      temp = tentero + (float) tdecimal/100;
      print ("Temperatura ", temp);
      x = CanalSerie.leerMedida() ;
      y = CanalSerie.leerMedida() ; 
      print (" (X,Y)=", x, ",", y);

      if (status == 2)
        estado = Estados.GUARDAR;
      else
        imgtermica.almacena(x, y, temp);
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
  CanalSerie.Start();
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
}
