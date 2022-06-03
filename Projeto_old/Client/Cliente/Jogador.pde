public class Jogador {
 
    
    //posX posY raio direcao energia agilidade 

    int posX;
    int posY;
    int raio;
    float direcao;
    float energia;
    float agilidade;
    
    Jogador(int posX, int posY, int raio, float direcao, float energia, float agilidade) {
     
      this.posX = posX;
      this.posY = posY;
      this.raio = raio;
      this.direcao = direcao;
      this.energia = energia;
      this.agilidade = agilidade;
    }
    
    
    public void draw( PApplet appc) {
      
      PImage aux = loadImage("./Assets/green.png");
      aux.resize(this.raio,this.raio);
      appc.image(aux,this.posX , this.posY );
      
  }
        
}
