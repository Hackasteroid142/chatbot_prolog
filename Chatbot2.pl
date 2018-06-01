%**************************DOMINIOS****************************
%	Chatbot = Lista de listas.
%	Seed = int.
%	Log = String.
%	Msg = String. 
%	User = Lista.
%**************************PREDICADOS**************************
%	beginDialog(Chatbot,Log,Seed,Log).
%	sendMessage(Msg,Chatbot,Log,Seed,Log).
%	endDialog(Chatbot,Log,Seed,Log).
%	logToString(Log,Log).
%	test(User,Chatbot,Log,Seed,Log).
%**************************METAS*******************************
% Objetivo principal: Crear un TDA Chatbot para mantener una conversacion con el usuario.
%**************************HECHOS******************************

chatbot(Chatbot,[["B: Buenos dias, bienvenido a nuestra tienda.","B: Buenas tardes,bienvenido a nuestra tienda.","B: Buenas noches,bienvenido a nuestra tienda."],
	["B: Hasta luego","B: Gracias por preferirnos","B: Que tenga un buen dia"],
	["B: ¿Desea pedir o conocer nuestros modelos y tamaños?", "B: ¿Quiere conocer nuestros modelos?","B: ¿Quiere conocer nuestros tamaños?"],
	["B: Tenemos rompecabezas de animales, paisajes y dibujos"],
	["B: Los rompecabezas son de 1000, 3000 y 5000 piezas", "B: Cada rompecabezas puede ser de 1000,3000 o 5000 piezas","B: Tenemos solo rompecabezas de 1000,3000 y 5000 piezas"],
	["B: Su orden sera procesada."],
	["B: Los de 1000 valen 10000, los de 3000 valen 30000 y los de 5000 valen 40000"],
	["B: Para pedir solo tiene que ingresar el modelo con su tamaño, uno por uno"],
	["B: Ingrese nuevamente un pedido"],
	["B: Quiere ingresar otro pedido?. Solo diga si o no."],
	["B: No comprendo. ¿Lo podria decir de otra manera?"]]).
claves([["hola","Buenas","Buenos"],
	["modelos","modelo","modelo?","modelos?"],
	["tamaños","tamaño","tamaños?"],
	["no","No"],
	["precio","precio?","precios","precios?"],
	["pedir","pide","pide?","pedir?"],
	["si","Si"],
	["favoritos","comprados","recomendar","recomendacion","recomiendas"]]).
user(User1,["hola","cuales son los tamaños?","me podrias decir tambien los modelos?","y los precios?","hasta luego"]).
listRef([H|_],0,H).
buscarClave(_,[],2).
recomendado([],Resp,_,Resp,_).
ocurrencia(_,[],0).

%busca elemento de la posicion

listRef([_|T],N,E):-N1 is N-1,
					listRef(T,N1,E).
%obtiene la respuesta
getResp(Chatbot,Seed,Pos,Resp):-chatbot(Chatbot,X),
								listRef(X,Pos,ListResp),
								listRef(ListResp,Seed,Resp).
%comienza la conversacion
beginDialog(Chatbot,InputLog,Seed,OutputLog):-get_time(T),stamp_date_time(T,date(_,_,_,H,M,_,_,_,_),'local'),
											atomics_to_string(["[",H,":",M,"]"," "],"",D),
											(((H>18;H<5),getResp(Chatbot,2,0,Resp));
												(H>12;H<19),getResp(Chatbot,1,0,Resp);
												(H>6;H<13),getResp(Chatbot,0,0,Resp)),
											atomics_to_string([InputLog,"[/--/]|",D,Resp,"|"],"",OutputLog).
											
											
%termina la conversacion
endDialog(Chatbot,InputLog,Seed,OutputLog):-rand(Seed,Random),
											get_time(T),stamp_date_time(T,date(_,_,_,H,M,_,_,_,_),'local'),
											atomics_to_string(["[",H,":",M,"]"," "],"",D),
											getResp(Chatbot,Random,1,Resp),
											atomics_to_string([InputLog,D,Resp,"|"],"",OutputLog).

%permite intercambio de mensaje 
sendMessage(Msg,Chatbot,InputLog,Seed,OutputLog):- claves(Claves),
												rand(Seed,Random),
												get_time(T),stamp_date_time(T,date(_,_,_,H,M,_,_,_,_),'local'),
												atomics_to_string(["[",H,":",M,"]"," "],"",D),
												atomics_to_string([InputLog,D,"U:",Msg],"",Msg2),
												split_string(Msg," ","",ListMsg),
												buscarClave(ListMsg,Claves,PosClave),
												((pedido(Msg),getResp(Chatbot,Random,9,Resp));
												((PosClave == 9,split_string(InputLog,"|","",InputLog2),
												recomendado(InputLog2,"No hay informacion suficiente",InputLog2,Aux,0),
												armarRecomendado(Aux,Resp));
												(not(PosClave == 9),not(pedido(Msg)),getResp(Chatbot,Random,PosClave,Resp)))),
												atomics_to_string([Msg2,"|",D,Resp,"|"],"",OutputLog).

%genera un numero random
rand(Num,Result):-plus(Num,8,Aux),
				Result is mod(Aux,3).

%revisa si el mensaje tiene alguna palabra clave
contieneClave(Msg,Lista):-member(X,Msg),
						member(X,Lista).

%revisa que palabra clave tiene
										
buscarClave(ListMsg,[Cl1|H2],PosClave):-contieneClave(ListMsg,Cl1),buscarClave(ListMsg,[],PosClave);
										not(contieneClave(ListMsg,Cl1)),buscarClave(ListMsg,H2,PosClave2),
										PosClave is PosClave2 + 1.
%verifica que sea un pedido
pedido(Msg):-split_string(Msg," ","",ListMsg),contieneClave(ListMsg,["animales","paisajes","dibujos"]),
				contieneClave(ListMsg,["1000","3000","5000"]).
%busca la orden mas pedida

recomendado([In|Cin],It,Log,Resp,Mayor):-pedido(In),ocurrencia(In,Log,Aux),
									((Aux>Mayor,recomendado(Cin,In,Log,Resp,Aux));
										(Aux=<Mayor,recomendado(Cin,It,Log,Resp,Mayor)));
									not(pedido(In)),recomendado(Cin,It,Log,Resp,Mayor).
									

%arma la frase para el usuario 
armarRecomendado(Resp,Recomend):-(Resp == "No hay informacion suficiente",
								string_concat("B: No hay"," informacion suficiente",Recomend));
								(not(Resp == "No hay informacion suficiente"),	
								split_string(Resp," ","",Msg2),
								intersection(Msg2,["paisajes","dibujos","animales"],PopTem),
								intersection(Msg2,["1000","3000","5000"],PopTam),
								listRef(PopTem,0,PopTem2),
								listRef(PopTam,0,PopTam2),
								atomics_to_string(["B: El mas comprado es ",PopTem2," con ",PopTam2," piezas"],"",Recomend)).

%revisa quien tiene mayor ocurrencia 
mayorOcurrencia(In,Log,Mayor,Max):-ocurrencia(In,Log,Aux),(Aux>Mayor,Max is Aux;
								Aux=<Mayor,Max is Mayor).

%verifica que ambos sean el mismo pedido
igualPedido(Msg,Frase):-split_string(Msg," ","",Msg2),
						split_string(Frase," ","",Frase2),
						intersection(Msg2,Frase2,Int),contieneClave(Int,["animales","paisajes","dibujos"]),
						contieneClave(Int,["1000","3000","5000"]).
%calcula cuantas veces aparece una frase

ocurrencia(Msg,[H|T],C):-igualPedido(Msg,H),ocurrencia(Msg,T,C1),C is C1+1;
						not(igualPedido(Msg,H)),ocurrencia(Msg,T,C).

%transforma la lista a string
logToStringAux([L],L):-write(L).
logToStringAux([L|T],StrResp):-string_concat(L,"\n",Linea),
						write(Linea),
						logToStringAux(T,StrResp).

logToString(Log,R):-split_string(Log,"|","",Aux),
					logToStringAux(Aux,S).
	
%ayuda al test
auxTest([],Chatbot,Log,Seed,Out):-endDialog(Chatbot,Log,Seed,Out).
auxTest([H|T],Chatbot,Log,Seed,Out):-
						sendMessage(H,Chatbot,Log,Seed,AuxOut),
						auxTest(T,Chatbot,AuxOut,Seed,Out).
%simula mensajes entre usuario y maquina
test(User,Chatbot,InputLog,Seed,OutputLog):-user(User,X),
											beginDialog(Chatbot,InputLog,Seed,Aux),
											auxTest(X,Chatbot,Aux,Seed,OutputLog).

cantidadConver([],0).								
cantidadConver([H|T],Num):-(H=="[/--/]",cantidadConver(T,Num1),Num is Num1+1);
							(not(H=="[/--/]"),cantidadConver(T,Num)).