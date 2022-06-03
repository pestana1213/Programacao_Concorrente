// Need G4P library
import g4p_controls.*;
import controlP5.*;

GTextArea server_connection_label; 
GLabel titulo_label; 
GButton registar_button; 
GButton cancelar_button; 
GButton login_button;
GButton opcoes_button;
GWindow menu_window;

GWindow registo_window;
GWindow login_window;


GWindow jogo_window;

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
Assets assets;

GTextField ip; 
GTextField porta; 
String ipLido = "";
String portaLida = "";


Criatura r1 = new Criatura(200, 400, 0 , 1);


boolean estadoJogo = false;
int state = 0;
int i = 0;
int f = 0;

Jogo jogo = new Jogo(new ArrayList<Jogador>(),new ArrayList<Criatura>(),new ArrayList<Obstaculo>(),new HashMap<Jogador,Float>());

PImage red , bg;
Conector con = new Conector();

import java.util.StringTokenizer;

public void setup(){
  size(1200, 800, JAVA2D);
  frameRate(60);
  assets = new Assets();
  menu();
 
  jogo_window = GWindow.getWindow(this, "Jogo", 0, 0, 1200, 800, JAVA2D);
  jogo_window.addDrawHandler(this, "drawJogo");
  jogo_window.setVisible(false);
  
}
/*

  Runnable r = new Runnable(){
      public void run(){
        try {        
            while (!con.read().equals("Comeca")){
              Thread.sleep(100);
            }
            
            println("Vou começar o jogo");
            getSurface().setVisible(false);
            jogo_window.setVisible(true);
            estadoJogo = true;
        }
        catch(Exception e ){}
    }
  };
  
  (new Thread(r)).start();


*/



public void draw(){
  background(230);
  fill(0);
  //r1.draw();
}

public void menu(){
  
  boolean ok = con.connect("172.26.112.1",12345);  
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setMouseOverEnabled(false);
  G4P.setDisplayFont("Arial", G4P.PLAIN, 16);
  G4P.setInputFont("Arial", G4P.PLAIN, 20);
  
  surface.setTitle("Jogo");
  server_connection_label = new GTextArea(this, 100, 150, 980, 110, G4P.SCROLLBARS_VERTICAL_ONLY | G4P.SCROLLBARS_AUTOHIDE);
  server_connection_label.setOpaque(true);
  server_connection_label.addEventHandler(this, "server_connection_label_change");
  
  titulo_label = new GLabel(this, 300, 40, 630, 60);
  titulo_label.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  titulo_label.setText("PROGRAMAÇÃO CONCORRENTE 2020/2021");
  titulo_label.setOpaque(false);
  

  
  login_button = new GButton(this, 460, 300, 230, 70);
  login_button.setText("Login");
  login_button.setLocalColorScheme(GCScheme.GREEN_SCHEME);
  login_button.addEventHandler(this, "login_button_click");
  
  registar_button = new GButton(this, 460, 400, 230, 70);
  registar_button.setText("Registar");
  registar_button.addEventHandler(this, "registar_button_click");
  
  cancelar_button = new GButton(this, 460, 500, 230, 70);
  cancelar_button.setText("Cancelar");
  cancelar_button.setLocalColorScheme(GCScheme.RED_SCHEME);
  cancelar_button.addEventHandler(this, "cancelar_button_click");
  
  opcoes_button = new GButton(this, 460, 600, 230, 70);
  opcoes_button.setText("Opções");
  opcoes_button.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  opcoes_button.addEventHandler(this, "opcoes_button_click");
  

  
    
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


public void registar(){
  
  registo_window = GWindow.getWindow(this, "Jogo_Registo", 600, 400, 500, 500, JAVA2D);
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
  String res = con.read();
  println("resposta do server" + res);
  server_connection_label.appendText(res);
  
} 


public void password_change(GPassword source, GEvent event) { 
  println("Password : " + password.getPassword());
  lastPassword = password.getPassword();
} 

public void close_registo_window (GWindow window) { 
  registo_window.setVisible(false);
  getSurface().setVisible(true);
  
} 



public void login(){
  
  
  registo_window = GWindow.getWindow(this, "Jogo Login", 600, 400, 500, 500, JAVA2D);
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
  registo_window.setVisible(false);
  getSurface().setVisible(true);
  
} 


public void concluir_login_button_click(GButton source, GEvent event) {  //<>//
  
  getSurface().setVisible(true);
  registo_window.setVisible(false);
  con.write("login " + lastNome + " " + lastPassword);
  String res = con.read();
  println("resposta do server" + res);
  server_connection_label.appendText(res);

  Runnable r = new Runnable(){
      public void run(){
        try {        
            while (!con.read().equals("Comeca")){
              Thread.sleep(100);
            }
            
            println("Vou começar o jogo");
            getSurface().setVisible(false);
            jogo_window.setVisible(true);
            estadoJogo = true;
            while(true){
              Thread.sleep(50);
              println("a\n");
              String estadoLido = con.read();
              println(estadoLido);
              //image(assets.green ,500 , 500 );
              //jogo_window.image(assets.green ,500 , 500 );
              updateJogo(estadoLido);
              //jogo.draw();
              
        
           } 
        }
        catch(Exception e ){}
    }
  };
  
  (new Thread(r)).start();

} 


synchronized public void drawJogo(PApplet appc, GWinData data) { 
  //print("aa\n");
  appc.background(250);
  appc.fill(0);
  if(estadoJogo){
    jogo.draw(appc);
  }
} 



public void jogar(){

}

public void cancelar(){
  
  
  registo_window = GWindow.getWindow(this, "Jogo Cancelar", 600, 400, 500, 500, JAVA2D);
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
  registo_window.setVisible(false);
  getSurface().setVisible(true);
  
} 


public void concluir_cancelar_button_click(GButton source, GEvent event) { 
  
  getSurface().setVisible(true);
  registo_window.setVisible(false);
  con.write("close_account " + lastNome + " " + lastPassword);
  String res = con.read();
  println("resposta do server" + res);
  server_connection_label.appendText(res);
  
} 





public void opcoes(){
  
  
  registo_window = GWindow.getWindow(this, "Jogo Conectar", 600, 400, 500, 500, JAVA2D);
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
  registo_window.setVisible(false);
  getSurface().setVisible(true);
  
} 


public void concluir_opcoes_button_click(GButton source, GEvent event) { 
  
  getSurface().setVisible(true);
  registo_window.setVisible(false);
  
  
  boolean ok = con.connect(ipLido,Integer.parseInt(portaLida));  
  if(!ok){
    server_connection_label.appendText("Não me consegui conectar :(");
  }
  else {
    server_connection_label.appendText("Conexão concluída com sucesso");
  }
  

  
} 




public void updateJogo(String res){

  
  StringTokenizer stk = new StringTokenizer(res," ");
    
  int numJogadores = new Integer(stk.nextToken()).intValue(); //<>//
  System.out.println(numJogadores); //<>//
  
  ArrayList<Jogador> jogadores = new ArrayList<Jogador>();
  
  for (int i = 0 ; i < numJogadores ; i++){
      
      int posX = new Integer(stk.nextToken()).intValue();
      int posY = new Integer(stk.nextToken()).intValue();
      int raio = new Integer(stk.nextToken()).intValue();
      float dir = new Float(stk.nextToken()).floatValue();
      float energia = new Float(stk.nextToken()).floatValue();
      float agilidade = new Float(stk.nextToken()).floatValue();
      
      Jogador p = new Jogador (posX , posY , raio , dir , energia , agilidade);
      jogadores.add(p);
      
  }
  
  ArrayList<Criatura> criaturas = new ArrayList<Criatura>();
  
  int numVerdes = new Integer(stk.nextToken()).intValue();
  System.out.println(numVerdes);
    
    for (int i = 0 ; i < numVerdes ; i++){
      
      int posX = new Integer(stk.nextToken()).intValue();
      int posY = new Integer(stk.nextToken()).intValue();
      float dir = new Float(stk.nextToken()).floatValue();
      int tipo = 0;
      
      Criatura c = new Criatura (posX , posY , dir , tipo);
      criaturas.add(c);
      
  }
  
  int numVermelhos = new Integer(stk.nextToken()).intValue();
  System.out.println(numVermelhos);
    
    for (int i = 0 ; i < numVermelhos ; i++){
      
      int posX = new Integer(stk.nextToken()).intValue();
      int posY = new Integer(stk.nextToken()).intValue();
      float dir = new Float(stk.nextToken()).floatValue();
      int tipo = 1;
      
      Criatura c = new Criatura (posX , posY , dir , tipo);
      criaturas.add(c);
      
  }
  
  ArrayList<Obstaculo> obstaculos = new ArrayList<Obstaculo>();
  
  int numObstaculos = new Integer(stk.nextToken()).intValue();
    System.out.println(numObstaculos);
    
    for (int i = 0 ; i < numObstaculos ; i++){
      
      int posX = new Integer(stk.nextToken()).intValue();
      int posY = new Integer(stk.nextToken()).intValue();
      int tamanho = new Integer(stk.nextToken()).intValue();
      
      Obstaculo o = new Obstaculo (posX , posY , tamanho);
      obstaculos.add(o);
      
  }

  jogo.update (jogadores, criaturas, obstaculos, new HashMap<Jogador,Float>());
}
