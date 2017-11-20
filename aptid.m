function y = aptid(p1,p2,p3)
    num = [0.349];
    den = [0.18 1];
    
    penalidade = 0;

    h = tf(num,den);

    p = pid(p1,p2,p3);

    MF = feedback(h*p,1);
    
    t = step(MF,0:0.02:20);
    t_acom = 10;
    
    for i=1:501
        if(t(i,1)>=0.9)
            if(abs(1-t(i,1))<=0.0001 && abs(1-t(i+1,1))<=0.0001)
                t_acom = (i-1)*0.02;
                break;
            end;
        end;
        
    end;
    penalidade = t_acom + max(t);
    
    y = penalidade;
end