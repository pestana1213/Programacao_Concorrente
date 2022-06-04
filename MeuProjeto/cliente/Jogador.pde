public class Jogador {
 
    
    //posX posY raio direcao energia agilidade 

    String nome;
    float posX;
    float posY;
    float raio;
    float direcao;
    float agilidade; //Talvez
    String nomePlayer;
    int tipo; // 0 = green , 1 = vermelho arrozado, 2 = azul
    int vitorias; 
    
    Jogador(String nome, float posX, float posY, float raio, float direcao, float agilidade, String nomePlayer,int tipo,int vitorias) {
     
      this.nome = nome;
      this.posX = posX;
      this.posY = posY;
      this.raio = raio;
      this.direcao = direcao;
      this.agilidade = agilidade;
      this.nomePlayer= nomePlayer;
      this.tipo = tipo; 
      this.vitorias = vitorias;
    }
    
    
    public void draw( PApplet appc) {
      /*
      PImage copyShape = assets.pacman.get();
      copyShape.resize(this.raio,this.raio);
      appc.image(copyShape,this.posX,this.posY);
      */

      if (nome.equals(nomePlayer)){
        appc.noStroke();        

        if(this.tipo == 0){
          appc.fill(color(0,255,0));
        }
        if(this.tipo == 1){
          appc.fill(color(255,20,147));
        }
        if(this.tipo == 2){
          appc.fill( color(0,0,255));
        }
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
        if(this.tipo == 0){
          appc.fill(color(0,255,0));
        }
        if(this.tipo == 1){
          appc.fill(color(255,20,147));
        }
        if(this.tipo == 2){
          appc.fill( color(0,0,255));
        }
        appc.ellipse(this.posX,this.posY,this.raio,this.raio);
        
        appc.pushMatrix();
        appc.translate(this.posX, this.posY);
        appc.rotate(this.direcao);
        appc.popMatrix();            
      
      
      }

     //GLabel label = new GLabel(appc,this.posX-raio/2,this.posY+raio/2, 300,20,this.nome);
     //label.setLocalColorScheme(GCScheme.YELLOW_SCHEME);
     //label.setOpaque(false);
  }
        
}
