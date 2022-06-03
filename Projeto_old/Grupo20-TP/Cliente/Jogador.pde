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
    String nomePlayer;
    
    Jogador(String nome, int pontuacao, float posX, float posY, float raio, float direcao, float energia, float agilidade, String nomePlayer) {
     
      this.nome = nome;
      this.pontuacao = pontuacao;
      this.posX = posX;
      this.posY = posY;
      this.raio = raio;
      this.direcao = direcao;
      this.energia = energia;
      this.agilidade = agilidade;
      this.nomePlayer= nomePlayer;
    }
    
    
    public void draw( PApplet appc) {
      /*
      PImage copyShape = assets.pacman.get();
      copyShape.resize(this.raio,this.raio);
      appc.image(copyShape,this.posX,this.posY);
      */
      
      
      if (nome.equals(nomePlayer)){
        appc.noStroke();
        appc.fill(color(255,255,0));
        appc.ellipse(this.posX,this.posY,this.raio,this.raio);
        
        appc.pushMatrix();
        appc.translate(this.posX, this.posY);
        appc.rotate(this.direcao);
        appc.triangle(this.raio/2 + 10, 0,
               0, -this.raio/2,
               0, this.raio/2);
        appc.popMatrix();         
      }
      else {
        appc.noStroke();
        appc.fill(color(255,184,3));
        appc.ellipse(this.posX,this.posY,this.raio,this.raio);
        
        appc.pushMatrix();
        appc.translate(this.posX, this.posY);
        appc.rotate(this.direcao);
        appc.triangle(this.raio/2 + 10, 0,
               0, -this.raio/2,
               0, this.raio/2);
        appc.popMatrix();            
      
      
      }

     //GLabel label = new GLabel(appc,this.posX-raio/2,this.posY+raio/2, 300,20,this.nome);
     //label.setLocalColorScheme(GCScheme.YELLOW_SCHEME);
     //label.setOpaque(false);
  }
        
}
