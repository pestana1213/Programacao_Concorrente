
class Criatura {
  
  public float velocidade = 1;
  public float posX;
  public float posY;
  //public PVector pos;
  public float dir;
  public int tipo;   // 0 = green , 1 = red
  public int tam;

 
  public Criatura( float posX, float posY, float dir, int tipo) {
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
        
    if(this.tipo == 0) appc.fill(color(0,255,0));
    if(this.tipo == 1) appc.fill(color(255,0,0));
    appc.ellipse(this.posX,this.posY,this.tam,this.tam);
    
    
    appc.pushMatrix();
    appc.translate(this.posX, this.posY);
    float Radians = (float)(this.dir * Math.PI) / 180;
    appc.rotate(Radians);
    appc.noStroke();
    appc.triangle(this.tam/2 + 15, 0,
           0, -this.tam/2,
           0, this.tam/2);
    appc.popMatrix();
  }

}
