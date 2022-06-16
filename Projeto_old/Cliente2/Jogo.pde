

import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.ArrayList;
import java.util.HashMap;

class Jogo {

  ArrayList<Jogador> players;
  ArrayList<Cristal> Cristais;
  ArrayList<Obstaculo> obstaculos;
  HashMap<String, Integer> pontos;
  //float thisPlayerPoints;
  //float adversaryPoints;
  Lock l;



  public Jogo (ArrayList<Jogador> players, ArrayList<Cristal> Cristais, ArrayList<Obstaculo> obstaculos, HashMap<String, Integer> pontos) {

      this.players  = players;
      this.Cristais = Cristais;
      this.obstaculos = obstaculos;
      this.pontos = pontos;
      this.l = new ReentrantLock();
  }

  void update (ArrayList<Jogador> players, ArrayList<Cristal> Cristais, ArrayList<Obstaculo> obstaculos, HashMap<String, Integer> pontos) {

    this.l.lock();
    try {
      this.players  = players;
      this.Cristais = Cristais;
      this.obstaculos = obstaculos;
      this.pontos = pontos;
    }finally{
      this.l.unlock();
    }
  }


  void draw( PApplet appc) {

    for(Cristal c: this.Cristais ) {
        c.draw(appc);
    }

    for(Obstaculo o: this.obstaculos) {
        o.draw(appc);
    }
    
    for(Jogador p: this.players) {
        p.draw(appc);
    }
    
    StringBuilder sb = new StringBuilder();
    Map<String, Integer> aux = sortByValue(this.pontos);
    for (Map.Entry<String, Integer> entry : aux.entrySet()) {
      sb.append(entry.getKey() + " = " + + entry.getValue() + "\n");

    }
    
    scores.setText(sb.toString());
    
  }
  
}
