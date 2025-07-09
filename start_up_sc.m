clear
clc


load Datax
 
Ts =1; 
N =200;
S=33;
M=8;
Veh=Datax{M};
Vveh=Veh(:,1)

Aveh=[diff([Vveh]);0];
[row, col]=find(Aveh>3.5);
Aveh(row, col)=3.5;
[row, col]=find(Aveh<-3);
Aveh(row, col)=-3;

[Ptrac,Qgen]=Veh_Ptrac([Vveh],[Aveh]);

Vspeed(:,1)=[0:length(Vveh)-1];
Vspeed(:,2)=Vveh;

Ptra(:,1)=[0:length(Ptrac)-1];
Ptra(:,2)=Ptrac';

Vpre=[];
Apre=[];

%% scenario generator
for i=1:length(Vveh(:,1))
    VpreS=[];
    PtracS=[];
    Ds=interp1(Veh(:,4),Veh(:,2),i,'pchip');  
    Vt=interp1(Veh(:,4),Veh(:,1),i,'pchip');
    At=Aveh(i); 
      for s=1:1:S
         Veh_hat=Datax{1,s};
         Aveh_hat=[diff(Veh_hat(:,1));0];
         [unique_x, idx] = unique(Veh_hat(:,2));unique_y = Veh_hat(idx,4);
         kk=interp1(unique_x,unique_y,Ds,'pchip');
         kk=round(kk);
         for k=1:1:N*Ts           
             hat_v=interp1(Veh_hat(:,4),Veh_hat(:,1),k+kk-1,'pchip');
             hat_Aveh=interp1(Veh_hat(:,4),Aveh_hat,k+kk-1,'pchip');
             Vse(s,k)=Vt*exp(-0.25*(k-1))+hat_v*(1-exp(-0.25*(k-1))); 
             Ase(s,k)=At*exp(-0.25*(k-1))+hat_Aveh*(1-exp(-0.25*(k-1)));
             if k+kk-1>length(Veh_hat(:,1))|Vse(s,k)>40|Vse(s,k)<0
                 Vse(s,k)=0;
                  Ase(s,k)=0;
             end
         end  
        [row, col]=find(Ase>3.5);
        Ase(row, col)=3.5;
        [row, col]=find(Ase<-3);
        Ase(row, col)=-3;   
        [Ptrac_s, ~]=Veh_Ptrac( Vse(s,:),Ase(s,:) );
        PtracS=[PtracS,Ptrac_s(1:Ts:N*Ts)];
        VpreS=[VpreS,Vse(s,1:Ts:N*Ts)];            
      end
    
 Vspeedpre(i,1)=i;
 Vspeedpre(i,2:N*S+1)=VpreS;
 Ptrpre(i,1)=i;
 Ptrpre(i,2:N*S+1)=PtracS;
 i
end

