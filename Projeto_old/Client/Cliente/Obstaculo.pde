class Obstaculo {

	public PVector pos;  
	public int tam;

	public Obstaculo(int posX , int posY , int tam){
		this.pos = new PVector(posX,posY);
		this.tam = tam;  
	}

    public void setPos(float posX , float posY){

        this.pos = new PVector(posX ,posY);

    }

	public void setTam(int tam){
        
        this.tam = tam;
        
    }

    public void draw(PApplet appc) {

      PImage aux = loadImage("./Assets/pedra.png");
      aux.resize(this.tam,this.tam);
      appc.image(aux,this.pos.x , this.pos.y );
      

  }
}
