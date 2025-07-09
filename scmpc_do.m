
import casadi.*

N=200;
Ts=1;
S=33;

T_max =30; T_min = 20;
n_min=100;n_max=2500;

x1 = SX.sym('x1'); x2 = SX.sym('x2');
states = [x1; x2]; 
n_states = length(states);


u1 = SX.sym('u1'); u2 = SX.sym('u2'); 
controls = [u1; u2]; 
n_controls = length(controls);

Q1 = SX.sym('Q1'); Q2 = SX.sym('Q2');

rhs = TransFun_total(states, controls, Q1, Q2); 

f = Function('f', {states, controls, Q1, Q2}, {rhs});


w={};  
U={};
w0=[];  
lbw=[]; 
ubw=[];
lbg=[];
ubg=[];
obj=0;
g={};

P=MX.sym('P',n_controls+N+N,S);
     
for s=1:S
X0=MX.sym(['X0_' num2str(s)],n_states);
w={w{:},X0};
lbw= [lbw; T_min; 10];         
ubw = [ubw; T_max; 50];         
w0 = [w0;29;29];

Xk=X0;
st=X0;
U={};    
for k=0:N-1
    Uk=MX.sym(['U_' num2str(s) '_' num2str(k)],n_controls); 
    w = {w{:}, Uk};           
    U={U{:},Uk};
    lbw = [lbw; n_min;n_min];          
    ubw = [ubw; n_max;n_max];          
    w0 = [w0;n_max;n_max];      
    
    st=Xk; con=Uk; Ptr=P(n_controls+k+1,s);V=P(n_controls+N+k+1,s);
    [P_com]=P_comXS(st,con,V);
    f_value = f(st,con,Ptr,V);
    Xk_end=st+(Ts*f_value);
    obj = obj+((P_com+P_pump(Uk(2)))/1000);%
    
    Xk = MX.sym(['X_' num2str(s) '_' num2str(k+1)], n_states);
    w = {w{:}, Xk};
    lbw = [lbw; T_min;10];
    ubw = [ubw; T_max;50];
    w0 = [w0;29;29];   

    g = [g{:};Xk_end-Xk]; 
    lbg=[lbg;0;0];
    ubg=[ubg;0;0];
end 
ust=[U{:,1}]; 
g=[g{:};ust-P(1:2,s)];
lbg=[lbg;-150;-150];
ubg=[ubg;150;150];
for j=2:N
    g=[g{:};U{:,j}-U{:,j-1}];
    lbg=[lbg;-150;-150];
    ubg=[ubg;150;150];
end
US{s}=U{1};
end

for s=2:S
    g=[g; US{s}-US{s-1}];
    lbg=[lbg;0;0];
    ubg=[ubg;0;0];
end

% Create an NLP solver
prob = struct('f', obj, 'x', vertcat(w{:}), 'g', vertcat(g{:}),'p',P);
opts = struct;
opts.ipopt.max_iter = 2000;
opts.ipopt.print_level =0;
opts.print_time = 0;
opts.ipopt.acceptable_tol =1e-8;
opts.ipopt.acceptable_obj_change_tol = 1e-6;
solver = nlpsol('solver', 'ipopt', prob, opts);

s0 = MX.sym('s0',2);
lbw_sym = MX(lbw);
ubw_sym = MX(ubw);
lbw_sym(1:2) = s0;
ubw_sym(1:2) = s0;

for s=1:S
    lbw_sym(1+(4*N+2)*(s-1):2+(4*N+2)*(s-1)) = s0;
    ubw_sym(1+(4*N+2)*(s-1):2+(4*N+2)*(s-1)) = s0;
end

sol_sym = solver('x0', w0, 'lbx', lbw_sym, 'ubx', ubw_sym,...
            'lbg', lbg, 'ubg', ubg,'p',P);

function_name = 'f';
U0=sol_sym.x(3:4);
f = Function(function_name,{s0,P},{U0});

file_name = 'f_scmpc.casadi';
f.save(file_name);

lib_path = GlobalOptions.getCasadiPath();
inc_path = GlobalOptions.getCasadiIncludePath();
mex('-v',['-I' inc_path],['-L' lib_path],'-lcasadi', 'casadi_fun.c')


function [Power]=P_pump(V_pump)
Power=(m1*V_pump^3+m2*V_pump^2+m3*V_pump);
end


