function splayAxisHorizontal(f,varargin)
% Display a bunch of axes horizonally
% Can input height,start,gap

if nargin == 0
    f=gcf;  
else
    if mod(length(varargin),2)==1   % passed a f...
        varargin=[{f} varargin];
        f=gcf;   
   end    
end

    
allAx=findobj(f, 'Type', 'axes', 'Box', 'off');
nAx=length(allAx);
if nAx==0
	return
end

gap=.05;
start=.07;
height=0.9;

% Parse input parameter pairs and rewrite values.
counter=1;
while counter+1 <= length(varargin)
    eval([varargin{counter} '=' num2str(varargin{counter+1}) ';']);
    counter=counter+2;
end

delta=(height-gap*(nAx-1))/nAx;

for counter=1:nAx
	set(allAx(nAx-counter+1), 'Position', [start+(counter-1)*(delta+gap) .07  delta .86 ]);
end