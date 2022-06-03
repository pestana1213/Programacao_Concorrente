class Assets {

  PImage background;
  PImage green;
  PImage red;
  PImage pedra;
  PImage player0;
  PImage player1;
  PImage pacman;

  Assets() {
    //   background = loadImage("./Assets/background.png");
    //  background.resize(1200, 800);


    this.green = loadImage("./Assets/green.png");
    this.green.resize(50,50);
    
    this.red = loadImage("./Assets/red.png");
    this.red.resize(50,50);
    
    this.pedra = loadImage("./Assets/pedra.png");   
    this.pacman = loadImage("./Assets/Pacman.png");
  }
}
