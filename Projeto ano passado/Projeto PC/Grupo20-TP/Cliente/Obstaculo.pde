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


    appc.fill(color(0,0,0));
    appc.ellipse(this.pos.x,this.pos.y,this.tam,this.tam);
      

  }
}
