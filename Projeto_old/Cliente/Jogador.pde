public class Jogador {
 
    
    //posX posY raio direcao energia agilidade 

    String nome;
    int pontuacao;
    float posX;
    float posY;
    float raio;
    float direcao;
    float energia;
    float agilidade;
    
    Jogador(String nome, int pontuacao, float posX, float posY, float raio, float direcao, float energia, float agilidade) {
     
      this.nome = nome;
      this.pontuacao = pontuacao;
      this.posX = posX;
      this.posY = posY;
      this.raio = raio;
      this.direcao = direcao;
      this.energia = energia;
      this.agilidade = agilidade;
    }
    
    
    public void draw( PApplet appc) {
      /*
      PImage copyShape = assets.pacman.get();
      copyShape.resize(this.raio,this.raio);
      appc.image(copyShape,this.posX,this.posY);
      */
      
      appc.fill(color(255,255,0));
      appc.ellipse(this.posX,this.posY,this.raio,this.raio);
      
      appc.pushMatrix();
      appc.translate(this.posX, this.posY);
      appc.rotate(this.direcao);
      appc.fill(255,255,0);
      appc.noStroke();
      appc.triangle(this.raio/2 + 10, 0,
             0, -this.raio/2,
             0, this.raio/2);
      appc.popMatrix();
      
     //GLabel label = new GLabel(appc,this.posX-raio/2,this.posY+raio/2, 300,20,this.nome);
     //label.setLocalColorScheme(GCScheme.YELLOW_SCHEME);
     //label.setOpaque(false);
  }
        
}
