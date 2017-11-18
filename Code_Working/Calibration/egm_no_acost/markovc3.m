function [chain,state]=markovc3(T,n,s0,V);

%  Chain generates a simulation from a Markov chain of dimension
%  the size of T
%
%  T is transition matrix
%  n is number of periods to simulate
%  s0 is initial state
%  V is the quantity corresponding to each state
%  state is a matrix recording the number of the realized state at time t
%
%  Modification of code from the toolbox accompanying the textbook 
%  by L. Ljungqvist/T. Sargent,
%
%
%  V has to be k x r,
%  where k is the dimension of V at each state,
%  r is the number of states
%
[r c]=size(T);
if nargin == 1;
  V=[1:r];
  s0=1;
  n=100;
end;
if nargin == 2;
  V=[1:r];
  s0=1;
end;
if nargin == 3;
  V=[1:r];
end;
%
if r ~= c;
  disp('error using markov function');
  disp('transition matrix must be square');
  return;
end;
%
for k=1:r;
  if abs(sum(T(k,:)) - 1) > 0.0000001;
    disp('error using markov function')
    disp(['row ',num2str(k),' does not sum to one']);
    disp(['normalizing row ',num2str(k),'']);
    T(k,:)=T(k,:)/sum(T(k,:));
  end;
end;
[v1 v2]=size(V);
if s0 < 1 |s0 > r;
  disp(['initial state ',num2str(s0),' is out of range']);
  disp(['initial state defaulting to 1']);
  s0=1;
end;
%
state = zeros(r,n);
X=rand(n-1,1);
s=zeros(r,1);
s(s0)=1;
cum=T*triu(ones(size(T)));
%
ppi=[0 s'*cum];

for k=1:length(X);
  state(:,k)=s;
  ppi(2:end)=s'*cum;
  s=((X(k)<=ppi(2:r+1)).*(X(k)>ppi(1:r)))';
end;
state(:,k+1)=s;
chain=V*state;





