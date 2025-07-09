function [ y ] = TransFun_total(x, u ,Ptrac,Vveh)% 

mb=;
cb=;
Ab=3.39292;
pc=1071.11;
cc=3330; 
hb=560;  
mclnt=9.21;
Vpump=33e-6;

ncom=u(1); npump=u(2);

Tamb=30;   

mair=0.07065+0.00606*Vveh;  
mc=Vpump*npump*pc/60;
Ppump=P_pump(npump);

T2=(x(2)-x(1))*exp(-hb*Ab/(mc*cc))+x(1);
Qcool=mc*cc*(T2-x(2));
Qamb=ha*(x(1)-Tamb)+Ab*0.8*1.380649e-23*(x(1)^4-Tamb^4);

Tin=T2;

lamda=Pcom_lambda(mair,Tamb);
beta=Qac_beta(mair,Tamb);
Pcom=lamda(1) + lamda(2)*ncom +lamda(3)*Tin +lamda(4)*ncom.^2 +lamda(5)*ncom.*Tin+lamda(6)*ncom.^3+lamda(7)*ncom.^2.*Tin;
Qac=(beta(1)+beta(2)*Pcom+beta(3)*Tin+beta(4)*mc+beta(5)*(Pcom.*Tin)+beta(6)*(Pcom.*mc)+beta(7)*(Pcom.^2));


Qgen=Battery_Qgen(Ptrac,Pcom,Ppump,x(1));

C_p1=mb*cb; 
C_p2=mclnt*cc;

dot1=( 1/C_p1*(Qgen-Qcool-Qamb) );
dot2=( 1/C_p2*(-Qac+mc*cc*(T2-x(2))));
y=[dot1;dot2];
end


function [Power]=P_pump(V_pump) %Ë®±Ã¹¦ºÄº¯Êý
Power=(m1*V_pump^3+m2*V_pump^2+m3*V_pump);
end



function lambda =Pcom_lambda(mair,Tamb)

lambda=[lambda1 lambda2 lambda3 lambda4 lambda5 lambda6 lambda7];
end

function beta=Qac_beta(mair,Tamb)

beta=[beta1 beta2 beta3 beta4 beta5 beta6 beta7];
end