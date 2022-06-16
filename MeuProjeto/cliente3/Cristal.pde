
class Cristal {
  
  public float velocidade = 1;
  public float posX;
  public float posY;
  //public PVector pos;
  public float dir;
  public int tipo;   // 0 = green , 1 = vermelho arrozado, 2 = azul
  public float tam;
 
  public Cristal( float posX, float posY, int tipo) {
    //this.pos = new PVector(posX, posY);
    this.posX = posX;
    this.posY = posY;
    this.tipo = tipo;
    this.tam = 25;
  }
  /*
  public void setPos(float posX, float posY, float dirX, float dirY){

    this.pos = new PVector(posX, posY);

  }
  */


  public void draw(PApplet appc) {
        
    appc.noStroke();
    if(this.tipo == 0) appc.fill(color(0,255,0));
    if(this.tipo == 1) appc.fill(color(255,20,147));
    if(this.tipo == 2 ) appc.fill(color(0,0,255)); 
    appc.ellipse(this.posX,this.posY,this.tam,this.tam);
    
    
    appc.pushMatrix();
    appc.translate(this.posX, this.posY);
    float Radians = (float)(this.dir * Math.PI) / 180;
    appc.rotate(Radians);
    appc.popMatrix();
  }

}
