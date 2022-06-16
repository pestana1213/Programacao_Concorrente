// Need G4P library //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
import g4p_controls.*;
import java.util.*;
import java.lang.*;
import java.util.StringTokenizer;
import java.awt.Font;

GTextArea server_connection_label; 
GLabel titulo_label; 
GButton registar_button; 
GButton cancelar_button; 
GButton login_button;
GButton opcoes_button;
GButton nova_partida;
GWindow menu_window;
GWindow registo_window;
GWindow login_window;


GWindow jogo_window;
GButton jogo_pontos_button;
GWindow pontos_Window;
GLabel scoresA;
GLabel perdeu_label;

GLabel password_label; 
GLabel nome_label; 
GLabel password_label_1; 
GLabel nome_label_1; 
GTextField nome; 
GButton concluir_registo_button;
GButton concluir_login_button; 
GPassword password;
String lastNome = "";
String lastPassword = "";

GTextField ip; 
GTextField porta; 
String ipLido = "";
String portaLida = "";

boolean threadMorreu = false;
boolean estadoJogo = false;
boolean apresentarPontos = false;
int state = 0;
int i = 0;
int f = 0;
int conta = 0;
Runnable runnablePontos;

Jogo jogo = new Jogo(new ArrayList<Jogador>(), new ArrayList<Cristal>(), new HashMap<String, Integer>());
PImage red, bg;
Conector con = new Conector();

HashMap<String, Integer> MelhoresPontuacoes = new HashMap<String, Integer>();
float energiaAtual=0;
float raioAtual=0;

Thread thread;
Thread ranking;
int andaThread = 0;

GLabel scores;
GLabel energia;
GLabel raio;
GLabel agilidadeLabel;

float agilidadeAtual;
Font font = new Font("Arial", Font.PLAIN, 18);

int contaCliques = 0;


public void setup() {
  size(1300, 700, JAVA2D);
  frameRate(60);
  pontos_Window = GWindow.getWindow(this, "Melhores Pontuações", 1150, 100, 300, 300, JAVA2D);
  pontos_Window.setActionOnClose(G4P.CLOSE_WINDOW);
  pontos_Window.addDrawHandler(this, "drawRanking");
  pontos_Window.addOnCloseHandler(this, "fecha_ranking_window");
  scoresA = new GLabel(pontos_Window, 35, 0, 200, 300, "");
  scoresA.setTextAlign(GAlign.CENTER, GAlign.TOP);
  scoresA.setLocalColorScheme(GCScheme.RED_SCHEME);
  scoresA.setOpaque(false);
  scoresA.setFont(font);
  pontos_Window.setVisible(false);
  menu();


}

public void close_jogo (GWindow window){
  
  estadoJogo = false;
  con.write("quit");
  getSurface().setVisible(true);
  perdeu_label.setText("");
  jogo_window.setVisible(false);

}

public void fecha_ranking_window(GWindow window) {
  pontos_Window.setVisible(false);
  apresentarPontos = false;
}

public void mouseMoved(PApplet applet, GWinData windata, MouseEvent ouseevent)  {
  con.write(ouseevent.getX() + " " + ouseevent.getY());
   
  if (ouseevent.getButton() == 37)
  {
    contaCliques ++;
    if (contaCliques == 3)
    {
      con.write("LEFT");
      contaCliques = 0;
    }
  }
}




void keyPressed_Handler(PApplet appc, GWinData data, KeyEvent event) {
  if (appc.keyPressed) {
    //println("Entrei no key pressed key = " + appc.key);
    con.write("" + appc.key);
  }
}

public void draw() {

  if (estadoJogo == false) {
    background(230);
    fill(0);
  }
}

public void menu() {

   //ipLido = "192.168.1.69";
   ipLido = "localhost";
   portaLida = "22343"; 
   boolean ok = con.connect(ipLido, Integer.parseInt(portaLida));  

  this.noLoop();
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setMouseOverEnabled(false);
  G4P.setDisplayFont("Arial", G4P.PLAIN, 16);
  G4P.setInputFont("Arial", G4P.PLAIN, 20);

  surface.setTitle("Jogo");
  server_connection_label = new GTextArea(this, 200, 150, 900, 110, G4P.SCROLLBARS_VERTICAL_ONLY | G4P.SCROLLBARS_AUTOHIDE);
  server_connection_label.setOpaque(true);
  server_connection_label.addEventHandler(this, "server_connection_label_change");

  titulo_label = new GLabel(this, 300, 40, 700, 60);
  titulo_label.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  titulo_label.setText("PROGRAMAÇÃO CONCORRENTE 2021/2022");
  titulo_label.setOpaque(false);

  titulo_label = new GLabel(this, 300, 80, 700, 60);
  titulo_label.setTextAlign(GAlign.CENTER, GAlign.TOP);
  titulo_label.setText("Battle Royale");
  titulo_label.setOpaque(false);

  login_button = new GButton(this, 150, 300, 300, 120);
  login_button.setText("Login");
  login_button.setLocalColorScheme(7);
  login_button.addEventHandler(this, "login_button_click");

  registar_button = new GButton(this, 800, 300, 300, 120);
  registar_button.setText("Registar");
  registar_button.setLocalColorScheme(5);
  registar_button.addEventHandler(this, "registar_button_click");

  cancelar_button = new GButton(this, 150, 500, 300, 120);
  cancelar_button.setText("Cancelar");
  cancelar_button.setLocalColorScheme(4);
  cancelar_button.addEventHandler(this, "cancelar_button_click");

  opcoes_button = new GButton(this, 800, 500, 300, 120);
  opcoes_button.setText("Opções");
  opcoes_button.setLocalColorScheme(3);
  opcoes_button.addEventHandler(this, "opcoes_button_click");

  nova_partida = new GButton(this, 475, 400, 300, 120);
  nova_partida.setText("Nova Partida");
  nova_partida.setLocalColorScheme(3);
  nova_partida.addEventHandler(this, "nova_partida_click");

  jogo_pontos_button = new GButton(this, 850, 60, 60, 60);
  jogo_pontos_button.setIcon("Assets/ranking.png", 1, GAlign.SOUTH, GAlign.CENTER, GAlign.MIDDLE);
  jogo_pontos_button.setLocalColorScheme(GCScheme.SCHEME_15);
  jogo_pontos_button.addEventHandler(this, "jogo_pontos_button_click");
  
  
  this.loop();
}

//#region menu
synchronized public void registo_window_draw(PApplet appc, GWinData data) { //_CODE_:registo_window:453092:
  appc.background(230);
  appc.fill(0);
  //registo_window.setVisible(true);
} 



public void server_connection_label_change(GTextArea source, GEvent event) { //_CODE_:server_connection_label:697017:
  println("server_connection_label - GTextArea >> GEvent." + event + " @ " + millis());
} 

public void opcoes_button_click(GButton source, GEvent event) { //_CODE_:registar_button:703554:
  println("registar_button - GButton >> GEvent." + event + " @ " + millis());
  opcoes();
  getSurface().setVisible(false);
} 

public void nova_partida_click(GButton source, GEvent event) { //_CODE_:registar_button:703554:
  println("nova_partida - GButton >> GEvent." + event + " @ " + millis());
  con.write("login " + lastNome + " " + lastPassword);

} 

public void registar_button_click(GButton source, GEvent event) { //_CODE_:registar_button:703554:
  println("registar_button - GButton >> GEvent." + event + " @ " + millis());
  registar();
  getSurface().setVisible(false);
} 


public void cancelar_button_click(GButton source, GEvent event) { //_CODE_:cancelar_button:610057:
  println("cancelar_button - GButton >> GEvent." + event + " @ " + millis());
  cancelar();
  getSurface().setVisible(false);
} 

public void login_button_click(GButton source, GEvent event) { //_CODE_:login_button:963696:
  println("login_button - GButton >> GEvent." + event + " @ " + millis());
  login();
  getSurface().setVisible(false);
} 
//#endregion


public void registar() {

  registo_window = GWindow.getWindow(this, "Jogo Registo", 600, 100, 500, 500, JAVA2D);
  registo_window.noLoop();
  registo_window.setActionOnClose(G4P.CLOSE_WINDOW);
  registo_window.addDrawHandler(this, "registo_window_draw");

  password_label = new GLabel(registo_window, 20, 260, 160, 40);
  password_label.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  password_label.setText("Palavra-Passe");
  password_label.setOpaque(false);

  nome_label = new GLabel(registo_window, 20, 120, 160, 40);
  nome_label.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  nome_label.setText("Nome :");
  nome_label.setOpaque(false);

  nome = new GTextField(registo_window, 220, 120, 220, 40, G4P.SCROLLBARS_NONE);
  nome.setOpaque(true);
  nome.addEventHandler(this, "nome_change");

  concluir_registo_button = new GButton(registo_window, 140, 380, 200, 60);
  concluir_registo_button.setText("REGISTAR");
  concluir_registo_button.addEventHandler(this, "concluir_registo_button_click");

  password = new GPassword(registo_window, 220, 260, 220, 40);
  password.setMaxWordLength(20);
  password.setOpaque(true);
  password.addEventHandler(this, "password_change");





  registo_window.addOnCloseHandler(this, "close_registo_window");

  registo_window.loop();
}





public void nome_change(GTextField source, GEvent event) { 
  println("Nome :" + nome.getText());
  lastNome = nome.getText();
} 

public void concluir_registo_button_click(GButton source, GEvent event) { 

  println("concluir_registo_button - GButton >> GEvent." + event + " @ " + millis());
  getSurface().setVisible(true);
  registo_window.setVisible(false);
  con.write("create_account " + lastNome + " " + lastPassword);
  lastNome = "";
  lastPassword = "";
  String res = "";
    try {
       while (res.equals("")){
         Thread.sleep(300);
         res = con.read();
         println("resposta do server" + res);
         server_connection_label.appendText(res);
       }
    }
    catch(Exception e) {
      
    }
      
  println("resposta do server" + res);
  server_connection_label.appendText(res);
} 


public void password_change(GPassword source, GEvent event) { 
  println("Password : " + password.getPassword());
  lastPassword = password.getPassword();
} 

public void close_registo_window (GWindow window) { 
  getSurface().setVisible(true);
  registo_window.setVisible(false);
} 


public void login() {


  registo_window = GWindow.getWindow(this, "Jogo Login", 600, 100, 500, 500, JAVA2D);
  registo_window.noLoop();
  registo_window.setActionOnClose(G4P.CLOSE_WINDOW);
  registo_window.addDrawHandler(this, "registo_window_draw");

  password_label = new GLabel(registo_window, 20, 260, 160, 40);
  password_label.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  password_label.setText("Palavra-Passe");
  password_label.setOpaque(false);

  nome_label = new GLabel(registo_window, 20, 120, 160, 40);
  nome_label.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  nome_label.setText("Nome :");
  nome_label.setOpaque(false);

  nome = new GTextField(registo_window, 220, 120, 220, 40, G4P.SCROLLBARS_NONE);
  nome.setOpaque(true);
  nome.addEventHandler(this, "nome_change");

  concluir_registo_button = new GButton(registo_window, 140, 380, 200, 60);
  concluir_registo_button.setText("LOGIN");
  concluir_registo_button.addEventHandler(this, "concluir_login_button_click");

  password = new GPassword(registo_window, 220, 260, 220, 40);
  password.setMaxWordLength(20);
  password.setOpaque(true);
  password.addEventHandler(this, "password_change");
  

  registo_window.addOnCloseHandler(this, "close_login_window");

  registo_window.loop();
}

public void close_login_window (GWindow window) { 
  getSurface().setVisible(true);
  registo_window.setVisible(false);
} 

public void criaJogoWindow() {
  jogo_window = null;
  jogo_window = GWindow.getWindow(this, "Jogo", 0, 0, 1300, 700, JAVA2D);
  jogo_window.addMouseHandler(this, "mouseMoved");

  jogo_window.setActionOnClose(G4P.CLOSE_WINDOW);
  jogo_window.setVisible(false);
  jogo_window.addDrawHandler(this, "drawJogo");
  jogo_window.addOnCloseHandler(this, "close_jogo");
  jogo_window.setVisible(false);
  
  
  scores = new GLabel(jogo_window, 35, 0, 200, 100, "");
  scores.setTextAlign(GAlign.CENTER, GAlign.TOP);
  scores.setLocalColorScheme(GCScheme.RED_SCHEME);
  scores.setOpaque(false);
  scores.setFont(font);


  agilidadeLabel = new GLabel(jogo_window, 850, 0, 200, 30, "");
  agilidadeLabel.setLocalColorScheme(GCScheme.RED_SCHEME);
  agilidadeLabel.setOpaque(false);
  agilidadeLabel.setFont(font);

  raio = new GLabel(jogo_window, 700, 0, 200, 30, "");
  raio.setLocalColorScheme(GCScheme.RED_SCHEME);
  raio.setOpaque(false);
  raio.setFont(font);
  
  
}


public void concluir_login_button_click(GButton source, GEvent event) { 

  getSurface().setVisible(true);
  registo_window.setVisible(false);
  con.write("login " + lastNome + " " + lastPassword);
  String res = "";
 
    try {
       while (res.equals("")){
         Thread.sleep(300);
         res = con.read();
         println("resposta do server" + res);
         server_connection_label.appendText(res);
       }
    }
    catch(Exception e) {
      
    }
      
    

    runnablePontos = new Runnable() {
    public void run() {
      try {  
          
          while (apresentarPontos) {
          
             
            println("THREAD PONTOS " + andaThread++);
            con.write("pontos");
            Thread.sleep(5000);
          }
          threadMorreu = true;
          
        }
      catch(Exception e ) {
      }
    }
  };
        

  Runnable r = new Runnable() {
    public void run() {
      try {        
        while (!con.read().equals("Comeca")) {
          Thread.sleep(300);
        }
        criaJogoWindow();
        println("Vou começar o jogo\n");
        getSurface().setVisible(false);
        estadoJogo = true;
        jogo_window.frameRate(60);
        jogo_window.setVisible(true);
        while (estadoJogo) {
          //println("a\n");
          String estadoLido = con.read();

          //println(estadoLido);

          if (estadoLido.equals("Perdeu") ) {
            perdeu_label = new GLabel(jogo_window, 0, 100, 1300, 400);
            perdeu_label.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
            perdeu_label.setFont(new Font("Arial", Font.PLAIN, 40));
            perdeu_label.setText("");
            perdeu_label.setOpaque(false);
            scores.setText("");
            raio.setText("");
            agilidadeLabel.setText("");
            perdeu_label.setText("PERDEU");
            jogo_pontos_button.setVisible(true);
            estadoJogo = false;
            
          } 
          else if (estadoLido.equals("Venceu") ) {
            perdeu_label = new GLabel(jogo_window, 0, 100, 1300, 400);
            perdeu_label.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
            perdeu_label.setFont(new Font("Arial", Font.PLAIN, 40));
            perdeu_label.setText("");
            perdeu_label.setOpaque(false);
            scores.setText("");
            raio.setText("");
            agilidadeLabel.setText("");
            println("Cona");
            perdeu_label.setText("VENCEU");
            jogo_pontos_button.setVisible(true);
            println("Visivel");
            estadoJogo = false;
            
          }       
          else {
            //conta++;
            //print("JOGO " + conta + "\n");
            if (!estadoLido.equals(""))
            {
              updateJogo(estadoLido);
            }
            
          }
          

          if (apresentarPontos && threadMorreu)
            {
              
              try {
                threadMorreu = false;
                ranking = new Thread(runnablePontos);
                ranking.start();
              }
              catch(Exception e ) {
              }
;
            }
        }
      }
      catch(Exception e ) {
      }
    }
  };

  thread = new Thread(r);
  thread.start();
} 

synchronized public void drawJogo(PApplet appc, GWinData data) { 

  
  try 
   {
      appc.background(255);
      appc.imageMode(CORNER);
      appc.fill(0);
      
      if (estadoJogo) {
        
        jogo.draw(appc);
      
        raio.setText("Raio: "+  Math.round(raioAtual));
        agilidadeLabel.setText("Agilidade: " + Math.round(agilidadeAtual * 100.0) / 100.0 +"");
     }
   }
   catch (Exception e){
     
   }
   

  }

  


synchronized public void drawRanking (PApplet appc, GWinData data) { 
  if (apresentarPontos) {
    appc.background(255);
    appc.fill(255, 255, 0);
    appc.fill(255, 0, 0);
    
    StringBuilder sb = new StringBuilder();
    
    if (MelhoresPontuacoes != null && MelhoresPontuacoes.size() != 0)
    {
      Map<String, Integer> aux = sortByValue(MelhoresPontuacoes);
      for (Map.Entry<String, Integer> entry : aux.entrySet()) {
        sb.append(entry.getKey() + " = " + + entry.getValue() + "\n");
      }
      scoresA.setText(sb.toString());
    }
    MelhoresPontuacoes.clear();
  }
  
} 




public void jogo_pontos_button_click(GButton source, GEvent event) {

  pontos_Window = GWindow.getWindow(this, "Melhores Pontuações", 1150, 100, 300, 300, JAVA2D);
  pontos_Window.setActionOnClose(G4P.CLOSE_WINDOW);
  pontos_Window.addDrawHandler(this, "drawRanking");
  pontos_Window.addOnCloseHandler(this, "fecha_ranking_window");
  scoresA = new GLabel(pontos_Window, 35, 0, 200, 100, "");
  scoresA.setTextAlign(GAlign.CENTER, GAlign.TOP);
  scoresA.setLocalColorScheme(GCScheme.RED_SCHEME);
  scoresA.setOpaque(false);
  scoresA.setFont(font);
  
  
  
  con.write("pontos"); 
  apresentarPontos = true;
  threadMorreu = true;

}



// function to sort hashmap by values
public static HashMap<String, Integer> sortByValue(HashMap<String, Integer> hm)
{
  // Create a list from elements of HashMap
  List<Map.Entry<String, Integer> > list =
    new LinkedList<Map.Entry<String, Integer> >(hm.entrySet());

  // Sort the list
  Collections.sort(list, new Comparator<Map.Entry<String, Integer> >() {
    public int compare(Map.Entry<String, Integer> o1, 
      Map.Entry<String, Integer> o2)
    {
      return (o2.getValue()).compareTo(o1.getValue());
    }
  }
  );

  // put data from sorted list to hashmap
  HashMap<String, Integer> temp = new LinkedHashMap<String, Integer>();
  for (Map.Entry<String, Integer> aa : list) {
    temp.put(aa.getKey(), aa.getValue());
  }
  return temp;
}


public void cancelar() {


  registo_window = GWindow.getWindow(this, "Jogo Cancelar", 600, 100, 500, 500, JAVA2D);
  registo_window.noLoop();
  registo_window.setActionOnClose(G4P.CLOSE_WINDOW);
  registo_window.addDrawHandler(this, "registo_window_draw");

  password_label = new GLabel(registo_window, 20, 260, 160, 40);
  password_label.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  password_label.setText("Palavra-Passe");
  password_label.setOpaque(false);

  nome_label = new GLabel(registo_window, 20, 120, 160, 40);
  nome_label.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  nome_label.setText("Nome :");
  nome_label.setOpaque(false);

  nome = new GTextField(registo_window, 220, 120, 220, 40, G4P.SCROLLBARS_NONE);
  nome.setOpaque(true);
  nome.addEventHandler(this, "nome_change");

  concluir_registo_button = new GButton(registo_window, 140, 380, 200, 60);
  concluir_registo_button.setText("ELIMINAR");
  concluir_registo_button.addEventHandler(this, "concluir_cancelar_button_click");

  password = new GPassword(registo_window, 220, 260, 220, 40);
  password.setMaxWordLength(20);
  password.setOpaque(true);
  password.addEventHandler(this, "password_change");

  registo_window.addOnCloseHandler(this, "close_cancelar_window");

  registo_window.loop();
}

public void close_cancelar_window (GWindow window) { 
  getSurface().setVisible(true);
  registo_window.setVisible(false);
} 


public void concluir_cancelar_button_click(GButton source, GEvent event) { 

  getSurface().setVisible(true);
  registo_window.setVisible(false);
  con.write("close_account " + lastNome + " " + lastPassword);
  String res = "";
    try {
       while (res.equals("")){
         Thread.sleep(300);
         res = con.read();
         println("resposta do server" + res);
         server_connection_label.appendText(res);
       }
    }
    catch(Exception e) {
      
    }
} 




public void opcoes() {


  registo_window = GWindow.getWindow(this, "Jogo Conectar", 600, 100, 500, 500, JAVA2D);
  registo_window.noLoop();
  registo_window.setActionOnClose(G4P.CLOSE_WINDOW);
  registo_window.addDrawHandler(this, "registo_window_draw");

  password_label = new GLabel(registo_window, 20, 260, 160, 40);
  password_label.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  password_label.setText("PORTA");
  password_label.setOpaque(false);

  nome_label = new GLabel(registo_window, 20, 120, 160, 40);
  nome_label.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  nome_label.setText("IP");
  nome_label.setOpaque(false);

  ip = new GTextField(registo_window, 220, 120, 220, 40, G4P.SCROLLBARS_NONE);
  ip.setOpaque(true);
  ip.addEventHandler(this, "ip_change");

  concluir_registo_button = new GButton(registo_window, 140, 380, 200, 60);
  concluir_registo_button.setText("FAZER LIGAÇÃO");
  concluir_registo_button.addEventHandler(this, "concluir_opcoes_button_click");

  porta = new GTextField(registo_window, 220, 260, 220, 40, G4P.SCROLLBARS_NONE);
  porta.setOpaque(true);
  porta.addEventHandler(this, "porta_change");

  registo_window.addOnCloseHandler(this, "close_cancelar_window");

  registo_window.loop();
}

public void ip_change(GTextField source, GEvent event) { 
  println("IP :" + ip.getText());
  ipLido = ip.getText();
} 

public void porta_change(GTextField source, GEvent event) { 
  println("Porta :" + porta.getText());
  portaLida = porta.getText();
} 




public void close_opcoes_window (GWindow window) { 
  getSurface().setVisible(true);
  registo_window.setVisible(false);
} 


public void concluir_opcoes_button_click(GButton source, GEvent event) { 

  getSurface().setVisible(true);
  registo_window.setVisible(false);


  boolean ok = con.connect(ipLido, Integer.parseInt(portaLida));  
  if (!ok) {
    server_connection_label.appendText("Não me consegui conectar :(");
  } else {
    server_connection_label.appendText("Conexão concluída com sucesso");
  }
  
} 



public synchronized void updateJogo(String res) {

  try 
  
  {
   
 //<>//
  //println("li isto " + res); //<>// //<>// //<>//
  StringTokenizer stk = new StringTokenizer(res, " ");

  if (stk.nextToken().equals("Pontos")) {
    MelhoresPontuacoes.clear();
    //println("Estou a ler pontos");
    int numJogadores = new Integer(stk.nextToken()).intValue();
    //println("Estou a ler pontos numjogadores" + numJogadores);
    for (int i = 0; i < numJogadores; i++) {
      String nome = new String(stk.nextToken());
      //println("Estou a ler pontos nome" + nome);
      int pontuacao = new Integer(stk.nextToken()).intValue();
      //println("Estou a ler pontos pontuacao" + pontuacao);
      MelhoresPontuacoes.put(nome, pontuacao);
      println(MelhoresPontuacoes.toString());
    }

    pontos_Window.setVisible(true);
    

  } else {

    //println("b");
    int numJogadores = new Integer(stk.nextToken()).intValue();

    ArrayList<Jogador> jogadores = new ArrayList<Jogador>();
    HashMap<String, Integer> pontos = new HashMap<String, Integer>();    

    for (int i = 0; i < numJogadores; i++) {

      String nome = new String(stk.nextToken());
      int vitorias = new Integer(stk.nextToken()).intValue();
      int tipo = new Integer(stk.nextToken()).intValue();
      float posX = new Float(stk.nextToken()).floatValue();
      float posY = new Float(stk.nextToken()).floatValue();
      float raio = new Float(stk.nextToken()).floatValue();
      float dir = new Float(stk.nextToken()).floatValue();
      float agilidade = new Float(stk.nextToken()).floatValue();
      
      if (lastNome.equals(nome)) {      
        raioAtual = raio;
        agilidadeAtual = agilidade;
        tipo = tipo;
      }

      Jogador p = new Jogador (nome, posX, posY, raio, dir, agilidade,lastNome,tipo,vitorias);
      jogadores.add(p);
      pontos.put(nome, vitorias);
    }

    ArrayList<Cristal> cristais = new ArrayList<Cristal>();

    int numVerdes = new Integer(stk.nextToken()).intValue();

    for (int i = 0; i < numVerdes; i++) {

      float posX = new Float(stk.nextToken()).floatValue();

      float posY = new Float(stk.nextToken()).floatValue();
      int tipo = 0;

      Cristal c = new Cristal (posX, posY, tipo);
      cristais.add(c);
    }

    int numVermelhos = new Integer(stk.nextToken()).intValue();

    for (int i = 0; i < numVermelhos; i++) {

      float posX = new Float(stk.nextToken()).floatValue();
      float posY = new Float(stk.nextToken()).floatValue();
      int tipo = 1;

      Cristal c = new Cristal (posX, posY, tipo);
      cristais.add(c);
    }

    int numAzuis = new Integer(stk.nextToken()).intValue();

    for (int i = 0; i < numAzuis; i++) {

      float posX = new Float(stk.nextToken()).floatValue();
      float posY = new Float(stk.nextToken()).floatValue();
      int tipo = 2;

      Cristal c = new Cristal (posX, posY, tipo);
      cristais.add(c);
    }


    jogo.update (jogadores, cristais, pontos);
    
  }
  }
  catch (Exception e)
  {
    //println(e);
  }
  
}
