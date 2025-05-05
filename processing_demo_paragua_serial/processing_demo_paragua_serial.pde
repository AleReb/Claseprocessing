import processing.serial.*;

Serial miPuerto;          // Puerto serie
int resolution = 60;
float radioMax = 200;
float aperturaMapeada = 0.05;  // Inicial

void setup() {
  size(800, 800, P3D);
  frameRate(30);
  println(Serial.list());
  // Ajusta el índice [0] si tu Arduino aparece en otra posición
  miPuerto = new Serial(this, Serial.list()[1], 9600);
  miPuerto.bufferUntil('\n');
}

void draw() {
  background(240);
  lights();

  // La apertura ya se actualizó en serialEvent()
  float rMaxLocal = radioMax * aperturaMapeada;

  translate(width / 2, height / 2, 0);
  rotateX(PI / 3);  // Vista inclinada
  drawUmbrella(rMaxLocal);
}

void drawUmbrella(float rMax) {
  float h = 200;
  for (int i = 0; i < resolution - 1; i++) {
    float r1 = map(i, 0, resolution, 0, rMax);
    float r2 = map(i + 1, 0, resolution, 0, rMax);

    beginShape(QUAD_STRIP);
    for (int j = 0; j <= resolution; j++) {
      float a = map(j, 0, resolution, 0, TWO_PI);

      float x1 = r1 * cos(a), y1 = r1 * sin(a);
      float z1 = -h * (1 - sq(r1 / rMax));
      float x2 = r2 * cos(a), y2 = r2 * sin(a);
      float z2 = -h * (1 - sq(r2 / rMax));

      vertex(x1, y1, z1);
      vertex(x2, y2, z2);
    }
    endShape();
  }
}

void serialEvent(Serial puerto) {
  String lectura = puerto.readStringUntil('\n');
  if (lectura != null) {
    lectura = trim(lectura);
    if (lectura.matches("\\d+")) {
      int sensorVal = int(lectura);
      // Mapear lectura (0–1023) a apertura realista 0.05–1.0
      aperturaMapeada = map(sensorVal, 0, 1023, 0.05, 1.0);
    }
  }
}
