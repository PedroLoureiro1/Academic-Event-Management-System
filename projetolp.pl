% Pedro Loureiro
% 107059
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % para listas completas
:- ["dados.pl"], ["keywords.pl"]. % ficheiros a importar.

/*E verdade se Eventos Sem Lista e uma lista ordenada, sem elementos repetidos de IDs sem sala */
eventosSemSalas(Eventos):-
    findall(ID, evento(ID,_,_,_,semSala), Eventos).

/*E verdade se Eventos Sem Lista e uma lista ordenada, sem elementos repetidos de IDs sem sala
de ids de de eventos sem sala num determinado dia da semana */
eventosSemSalasDiaSemana(DiaSemana, EventosSemSala):-
    eventosSemSalas(Eventos),
    findall(ID, (horario(ID, DiaSemana,_,_,_,_), member(ID, Eventos)), EventosSemSala).


/*funcao que permite chegar ao semestre a que o periodo pertence
--->semestre(Periodo,Semestre)*/
    semestre(p1,p1_2).
    semestre(p2,p1_2).
    semestre(p3,p3_4).
    semestre(p4,p3_4).

/*funcao permite adicionar os semestres correspondentes aos periodos passados na lista*/
adicionaSemestres(ListaPeriodos,ListaPeriodosComSemestres):-
    findall(Semestre,(semestre(Periodo,Semestre),member(Periodo,ListaPeriodos)),ListaSemestres),
    append(ListaPeriodos,ListaSemestres,ListaPeriodosComSemestres).

/*E verdade se Lista Periodos e uma lista de periodos e Eventos Sem Sala
e uma lista ordenada e sem elementos repetidos de ids nos periodos provenientes da lista.
Considera tambem os semestres associados aos periodos da lista. */
eventosSemSalasPeriodo(ListaPeriodos, EventosSemSala):-
    adicionaSemestres(ListaPeriodos,ListaPeriodosComSemestres),
    eventosSemSalas(Eventos),
    findall(ID, (horario(ID,_,_,_,_,Periodo), 
    member(Periodo,ListaPeriodosComSemestres), 
    member(ID, Eventos)),EventosSemSala_Aux),
    sort(EventosSemSala_Aux,EventosSemSala).

/*E verdade se Eventos no Periodo e uma lista ordenada e sem elementos repetidos
de ids dos eventos na lista eventos num determinado periodo.*/
%mal feito

organizaEventos(ListaEventos,Periodo,EventosNoPeriodo):-
    organizaEventosAux(ListaEventos,Periodo,ListaEventosAux),
    sort(ListaEventosAux,EventosNoPeriodo).

organizaEventosAux([], _, []):-!.

organizaEventosAux([P|R], Periodo, [P|EventosNoPeriodo]):-
    semestre(Periodo, Semestre),
    (horario(P,_,_,_,_,Periodo);
    horario(P,_,_,_,_,Semestre)), !,
    organizaEventosAux(R, Periodo, EventosNoPeriodo).

organizaEventosAux([P|R], Periodo, EventosNoPeriodo):-
    horario(P,_,_,_,_,Periodo_Atual),
    Periodo_Atual \== Periodo,
    organizaEventosAux(R, Periodo, EventosNoPeriodo).

/*E verdade se Lista Eventos Menores Que e a lista ordenada e sem elementos
repetidos dos identificadores dos eventos que tem duracao menor ou igual a Duracao.*/
eventosMenoresQue(Duracao, ListaEventosMenoresQue):-
    findall(ID, (horario(ID,_,_,_,TempoAula,_), TempoAula =< Duracao), ListaEventosMenoresQue). 

/*E verdade se evento identificado por id tiver duracao menor ou igual a dada.*/
eventosMenoresQueBool(ID, Duracao):-
    horario(ID,_,_,_,TempoAula,_),
    TempoAula=<Duracao.

/*E verdade se Lista Disciplinas e a lista ordenada alfabeticamente do
nome das disciplinas do curso dado. */
procuraDisciplinas(Curso, ListaDisciplinas):-
    findall(NomeDisciplina, (evento(ID,NomeDisciplina,_,_,_), turno(ID, Curso,_,_)), ListaAux),
    sort(ListaAux, ListaDisciplinas).

/*E verdade se Semestres e uma lista com duas listas dentro. A primeira lista
contem as disciplinas lecionados no primeiro semestre e a segunda lista para
as disciplinas do segundo semestre. Falha caso nenhuma das disciplinas seja
lecionada no curso dado.*/
organizaDisciplinas([],_,[[],[]]):-!.

organizaDisciplinas([P|R],Curso,[[P|Semestre1],Semestre2]):-
    evento(ID,P,_,_,_),
    turno(ID,Curso,_,_),
    horario(ID,_,_,_,_,Periodo),
    member(Periodo,[p1,p2,p1_2]),!,
    organizaDisciplinas(R,Curso,[Semestre1,Semestre2]).

organizaDisciplinas([P|R],Curso,[Semestre1,[P|Semestre2]]):-
    evento(ID,P,_,_,_),
    turno(ID,Curso,_,_),
    horario(ID,_,_,_,_,Periodo),
    member(Periodo,[p3,p4,p3_4]),!,
    organizaDisciplinas(R,Curso,[Semestre1,Semestre2]).

/*E verdade se Total Horas for o numero de horas total dos eventos, num dado
ano e periodo de um curso dado. */
horasCurso(Periodo, Curso, Ano, TotalHoras):-
    semestre(Periodo,Semestre),
    findall(ID,(turno(ID,Curso,Ano,_), (horario(ID,_,_,_,_,Periodo);horario(ID,_,_,_,_,Semestre))),IDs_Aux),
    sort(IDs_Aux,IDs),
    findall(Duracao,(horario(ID,_,_,_,Duracao,_),member(ID,IDs)),ListaDuracoes),
    sumlist(ListaDuracoes,TotalHoras).

/*E verdade se Evolucao for uma lista de tuplos na forma(Ano, Periodo, NumHoras)
em que Num Horas e o numero de horas de aulas num dado ano e periodo de um curso dado.*/
evolucaoHorasCurso(Curso, Evolucao):-
    findall((Ano, Periodo, TotalHoras), 
    (member(Ano,[1,2,3]), 
    member(Periodo, [p1,p2,p3,p4]), 
    horasCurso(Periodo,Curso,Ano,TotalHoras)),Evolucao).

/*E verdade se Horas for o numero de horas sobrepostas. Falha se nao
existirem sobreposicoes.*/
ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, Horas):-
    ((HoraInicioDada=<HoraInicioEvento),(HoraFimDada>=HoraFimEvento), Horas is HoraFimEvento - HoraInicioEvento), !;
    ((HoraInicioDada>=HoraInicioEvento),(HoraFimDada>=HoraFimEvento), (HoraFimEvento>=HoraInicioDada), Horas is HoraFimEvento - HoraInicioDada), !;
    ((HoraInicioDada=<HoraInicioEvento),(HoraFimDada=<HoraFimEvento), (HoraFimDada>=HoraInicioEvento), Horas is HoraFimDada - HoraInicioEvento), !;
    ((HoraInicioDada>=HoraInicioEvento),(HoraFimDada=<HoraFimEvento), Horas is HoraFimDada - HoraInicioDada), !.

/*E verdade se Soma Horas for o numero de horas ocupadas nas for o numero
de horas ocupadas das salas de um certo tipo num dado intervalo de tempo. */
numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras):-
    semestre(Periodo,Semestre),
    findall(Horas,
    (evento(ID,_,_,_,Sala),
    salas(TipoSala,Salas),
    member(Sala,Salas),
    (horario(ID,DiaSemana,HoraInicioEvento,HoraFimEvento,_,Periodo);
    horario(ID,DiaSemana,HoraInicioEvento,HoraFimEvento,_,Semestre)),
    ocupaSlot(HoraInicio,HoraFim,HoraInicioEvento,HoraFimEvento,Horas)),SomaHoras_Aux),
    sum_list(SomaHoras_Aux, SomaHoras).

/*E verdade se Max for o numero de horas possiveis de ser ocupadas por tipo 
de sala num intervalo dado. */
ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max):-
    salas(TipoSala,ListaSalas),
    length(ListaSalas, NumSalas),
    Max is ((HoraFim - HoraInicio) * NumSalas).

/*E verdade se percentagem for a divisao de somahoras por max~
multiplicado por 100. */
percentagem(SomaHoras, Max, Percentagem):-
    Percentagem is SomaHoras/Max*100.

/*E verdade se Resultados for uma lista ordenada de tuplos do tipo 
casosCriticos(DiaSemana, TipoSala, Percentagem) */
ocupacaoCritica(HoraInicio, HoraFim, Threshold, Resultados):-
    findall(casosCriticos(DiaSemana, TipoSala, Percentagem),
    (member(DiaSemana, [segunda-feira , terca-feira, quarta-feira, quinta-feira, sexta-feira, sabado]),
    member(Periodo, [p1,p2,p3,p4]), 
    ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max),
    numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras),
    percentagem(SomaHoras,Max,Percentagem_Aux),
    Percentagem_Aux > Threshold,
    Percentagem is ceiling(Percentagem_Aux)), Resultados_Aux),
    sort(Resultados_Aux, Resultados).

/*Senta as pessoas na mesa consoante a lista de restricoes passadas.*/
ocupacaoMesa(ListaPessoas, ListaRestricoes, OcupacaoMesa) :-
    OcupacaoMesa = [[X1, X2, X3], [X4, X5], [X6, X7, X8]],
    permutation(ListaPessoas, [X1, X2, X3, X4, X5, X6, X7, X8]),
    cumpreRestricoes(ListaRestricoes, OcupacaoMesa).

pessoaNoLugar(OcupacaoMesa, ListaIndex, LugarIndex, Pessoa):-
    nth0(ListaIndex, OcupacaoMesa, Lista),
    nth0(LugarIndex, Lista, Pessoa).

frenteAFrente([],[],_,_):- false.              

frenteAFrente([L|_], [O|_], Nome1, Nome2):-
    ((L == Nome1, O == Nome2);(L == Nome2, O == Nome1)),
    !.

frenteAFrente([_|Ls], [_|Os], Nome1, Nome2):-
    frenteAFrente(Ls, Os, Nome1, Nome2).

ladoALado(Lugares, Nome1, Nome2):-
    nth0(0, Lugares, L1),
    nth0(1, Lugares, L2),
    nth0(2, Lugares, L3),
    ((L1 == Nome1, L2 == Nome2);(L1 == Nome2, L2 == Nome1);
     (L3 == Nome1, L2 == Nome2);(L3 == Nome2, L2 == Nome1)).

cumpreRestricoes([], _).
cumpreRestricoes([R|Restantes], OcupacaoMesa) :-
    cumpreRestricao(R, OcupacaoMesa),
    cumpreRestricoes(Restantes, OcupacaoMesa).

cumpreRestricao(cab1(Nome), OcupacaoMesa) :-
    pessoaNoLugar(OcupacaoMesa, 1, 0, X4),
    Nome == X4.

cumpreRestricao(cab2(Nome), OcupacaoMesa) :- 
    pessoaNoLugar(OcupacaoMesa, 1, 1, X5),
    Nome == X5.

cumpreRestricao(honra(Nome1, Nome2), OcupacaoMesa) :-        
    pessoaNoLugar(OcupacaoMesa, 1, 0, X4),
    pessoaNoLugar(OcupacaoMesa, 2, 0, X6),
    pessoaNoLugar(OcupacaoMesa, 1, 1, X5),
    pessoaNoLugar(OcupacaoMesa, 0, 2, X3),
    ((Nome1 == X4, Nome2 == X6);(Nome1 == X5, Nome2 == X3)).

cumpreRestricao(lado(Nome1, Nome2), OcupacaoMesa) :-    
    nth0(0, OcupacaoMesa, LadoLareira),
    nth0(2, OcupacaoMesa, OutroLado),
    (ladoALado(LadoLareira, Nome1, Nome2);ladoALado(OutroLado, Nome1, Nome2)).

cumpreRestricao(naoLado(Nome1, Nome2), OcupacaoMesa) :-
    \+cumpreRestricao(lado(Nome1, Nome2), OcupacaoMesa).
          
cumpreRestricao(frente(Nome1, Nome2), OcupacaoMesa) :-
    nth0(0, OcupacaoMesa, LadoLareira),
    nth0(2, OcupacaoMesa, OutroLado),
    frenteAFrente(LadoLareira, OutroLado, Nome1, Nome2).

cumpreRestricao(naoFrente(Nome1, Nome2), OcupacaoMesa) :-      
    \+cumpreRestricao(frente(Nome1, Nome2), OcupacaoMesa).