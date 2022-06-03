class Assets {
  PImage green;
  PImage pink;
  PImage blue;

  PImage cristal_rosa;
  PImage cristal_azul;
  PImage cristal_verde;
/*
  PImage player0;
  PImage player1;
  PImage pacman;
*/

  Assets() {
    //   background = loadImage("./Assets/background.png");
    //  background.resize(1200, 800);


    this.green = loadImage("./Assets/avatar_verde.png");
    this.green.resize(50,50);
    
    this.pink = loadImage("./Assets/avatar_rosa.png");
    this.pink.resize(50,50);
    
    this.cristal_rosa = loadImage("./Assets/cristal_rosa.png");   
    this.cristal_azul = loadImage("./Assets/cristal_azul.png");
    this.cristal_verde = loadImage("./Assets/cristal_verde.png");

  }
}
