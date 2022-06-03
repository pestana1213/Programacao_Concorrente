
class Criatura {
  
  public float velocidade = 1;
  public int posX;
  public int posY;
  //public PVector pos;
  public float dir;
  public int tipo;   // 0 = green , 1 = red
  public int tam;

 
  public Criatura( int posX, int posY, float dir, int tipo) {
    //this.pos = new PVector(posX, posY);
    this.posX = posX;
    this.posY = posY;
    this.dir = dir;
    this.tipo = tipo;
    this.tam = 50;
  }
  /*
  public void setPos(float posX, float posY, float dirX, float dirY){

    this.pos = new PVector(posX, posY);

  }
  */


  public void draw(PApplet appc) {
        
    if( this.tipo == 0) {
      appc.image(assets.green ,this.posX , this.posY );
      }
    else {
      appc.image(assets.red , this.posX , this.posY);
    }
  }

}
