function [ Ptrac,Qgen] = Veh_Ptrac( Vveh,Aveh )
g=9.81;%重力加速度
Cr=0.015;
mveh=2100;%kg 2200
Pa=1.209; % 空气密度
Af=3.2;
Cd=0.3;
Fr=Cr*mveh*g;
for i=1:1:length(Aveh)
    Fa=0.5*Pa*Af*Cd*Vveh(i)^2;
    Ptrac(i)=Vveh(i)*(Fr+Fa+mveh*Aveh(i));
end
end