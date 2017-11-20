% WILSON JUNIOR
% 05/08/2017
% ALGORITMO GENETICO PARA ESTIMACAO DE PARAMETROS DE UM CONTROLADOR PID
%  // "O MUNDO VAI DIZER QUEM FOI GRANDE DE VERDADE." //

quantidade = 150;
B = 0.95;
geracoes = 20;

% CONSTANTES DO PID
kp = 100*rand(quantidade,1);
ti = 100*rand(quantidade,1);
td = 0.001*rand(quantidade,1);

% POPULACAO INICIAL
populacao = [kp ti td];

% MELHORES A CADA GERACAO
melhores = zeros(geracoes,3);

for contagem=1:geracoes

    % CALCULO DA APTIDAO DA POPULACAO
    aptidao = zeros(1,quantidade);
    for i=1:quantidade
       aptidao(1,i) = aptid(populacao(i,1),populacao(i,2),populacao(i,3));
    end

    % SELECAO NATURAL
    % SELECAO POR TORNEIO
    selecao = zeros(quantidade,3);
    for i=1:quantidade
        index1 = randi([1 quantidade],1);
        index2 = randi([1 quantidade],1);
        if(aptidao(1,index1)<=aptidao(1,index2))
            selecao(i,:) = populacao(index1,:);
        else
            selecao(i,:) = populacao(index2,:);
        end;
    end

    % REPRODUCAO DA POPULACAO
    % BLEND CROSSOVER
    filhos = zeros(quantidade,3);
    for i=1:quantidade
        crossover = rand();
        if(crossover>0.6 && crossover<0.9)
           index1 = randi([1 quantidade],1);
           index2 = randi([1 quantidade],1);
           filhos(i,:) = selecao(index1,:) + B*(selecao(index2,:)-selecao(index1,:));
        else
           filhos(i,:) = selecao(i,:);
        end
    end

    % MUTACAO DA POPULACAO
    % MUTACAO CREEP
    for i=1:quantidade
      for j=1:3
        mutacao = rand();
        if(mutacao<0.01)
            filhos(i,j) = filhos(i,j) + rand();
        end;
      end
    end

    % ELITISMO
    % PERMITINDO QUE O MELHOR INDIVIDUO SOBREVIVA
    maximo = filhos(1,:);
    indice_maximo = 1;
    minimo = populacao(1,:);
    indice_minimo = 1;
    for i=1:quantidade
       % APTIDAO DO INDIVIDUO i
       aptidao1 = aptid(populacao(i,1),populacao(i,2),populacao(i,3));

       % APTIDAO DO FILHO i
       aptidao2 = aptid(filhos(i,1),filhos(i,2),filhos(i,3));

       % APTIDAO DO FILHO MAXIMO
       aptidao3 = aptid(maximo(1,1),maximo(1,2),maximo(1,3));

       % APTIDAO DO INDIVIDUO MINIMO
       aptidao4 = aptid(minimo(1,1),minimo(1,2),minimo(1,3));

       if(aptidao2 < aptidao3)
          maximo = filhos(i,:);
          indice_maximo = i;
       end;

       if(aptidao1 > aptidao4)
           minimo = populacao(i,:);
           indice_minimo = i;
       end;

    end
    
    populacao(indice_minimo,:) = filhos(indice_maximo,:);
    
    % BUSCA O MELHOR INDIVIDUO DA POPULACAO A CADA GERACAO
       maximo = populacao(1,:);
       for i=1:quantidade
          aptidao1 = aptid(populacao(i,1),populacao(i,2),populacao(i,3));
          
          aptidao2 = aptid(maximo(1,1),maximo(1,2),maximo(1,3));
          if(aptidao1 < aptidao2)
            maximo(1,:) = populacao(i,:);
          end;
       end
       melhores(contagem,:) = maximo(1,:);
       disp(maximo);
    
end

% PLOTANDO OS RESULTADOS
t = 0:0.02:10;

% funcao de transferencia
g = tf([0.349],[0.18 1]);
st1 = step(feedback(g,1),t);

% pid do ultimo melhor individuo
x = size(melhores);
p2 = pid( melhores(x(1,1),1), melhores(x(1,1),2), melhores(x(1,1),3));
st3 = step(feedback(g*p2,1),t);

% pid sintonizado manualmente
p = pid(6,6/0.18,6*0.0001167);
st2 = step(feedback(g*p,1),t);

plot(t,st1,'b-',t,st3,'r-',t,st2,'g-')

