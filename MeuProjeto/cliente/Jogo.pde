

import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.ArrayList;
import java.util.HashMap;

class Jogo {

  ArrayList<Jogador> players;
  ArrayList<Cristal> cristais;
  HashMap<String, Integer> vitorias; 
  Lock l;



  public Jogo (ArrayList<Jogador> players, ArrayList<Cristal> cristais,HashMap<String, Integer> vitorias) {

      this.players  = players;
      this.cristais = cristais;
      this.vitorias = vitorias;
      this.l = new ReentrantLock();
  }

  void update (ArrayList<Jogador> players, ArrayList<Cristal> cristais,HashMap<String, Integer> vitorias) {

    this.l.lock();
    println("Teste UPDATE");
    try {
      this.players  = players;
      this.cristais = cristais;
      this.vitorias = vitorias;
    }finally{
      this.l.unlock();
    }
  }


   void draw( PApplet appc) {

    for(Cristal c: this.cristais ) {
        c.draw(appc);
    }
    
    for(Jogador p: this.players) {
        p.draw(appc);
    }
    
    StringBuilder sb = new StringBuilder();
    Map<String, Integer> aux = sortByValue(this.vitorias);
    for (Map.Entry<String, Integer> entry : aux.entrySet()) {
      sb.append(entry.getKey() + " = " + + entry.getValue() + "\n");

    }
    
    scores.setText(sb.toString());
    
  } 
  
}
