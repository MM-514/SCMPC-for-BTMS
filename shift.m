function [t0, x0, u0,U0] = shift(T, t0, x0, u,f,Q,V)
st = x0;
con = u(1,:)';
f_value = f(st,con,Q,V);
st = st+ (T*f_value);
x0 = full(st);

t0 = t0 + T;
u0= u(1,:)';
U0 = [u(2:size(u,1),:);u(size(u,1),:)];
end