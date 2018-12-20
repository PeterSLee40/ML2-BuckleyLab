function Y=magicwand3D(X,m,n,p,Tol,neighbornum)
% MAGICWAND3D - select pixels around fixed position (m,n,p)
%		with values within a preset tolerance
%
% 	Y = MAGICWAND3D(X,m,n,p)
%
%	Y = MAGICWAND3D(X,m,n,p,Tol)
%		Tol : tolerance (default is 0.01)
%
%	Y = MAGICWAND3D(X,m,n,p,Tol,neighbornum)
%		neighbornum can be '6','18', or '26'
%		(make sure you use single quotation mark around it)
%		depending on whether to include in-plane and/or
%		out-of-plane diagonal elements. 26 includes a cubic region
%		completely enclosing your pixel.
%
% made by Kijoon Lee on March 12, 2004.
% amended by Erin Buckley on Jan 9, 2008 to work with MRI data
%
%	See also MAGICWAND2D

%nargin=# of function arguments
if nargin<6
    neighbornum='6';
end
if nargin<5
    Tol=0.01;
end
if nargin<4
    error('Too small number of arguments. See the help.');
end

%X is the image you are trying to use magic wand on, M,N,P is its size
[M,N,P]=size(X);

%Make a matrix, Y, of 0's the size of X
Y=zeros(M,N,P);

%Position of pixel
pos_stack = [m n p];

%Define value in Y at the pixel location to be 1
Y(m,n,p)=1;

start_id = 1; end_id = 1;

REF = X(m,n,p);

while 1,
    %i=1
    for i=start_id:end_id
        
        %xind=m, yind=n, zind=p
        xind=pos_stack(i,1);yind=pos_stack(i,2);zind=pos_stack(i,3);
        
        neighbor=[];
        
        %find location of all, neighbors
        switch neighbornum
            case{'6','18','26'}
                if xind>1 neighbor=[neighbor;xind-1 yind zind]; end
                if yind>1 neighbor=[neighbor;xind yind-1 zind]; end
                if zind>1 neighbor=[neighbor;xind yind zind-1]; end
                if xind<M neighbor=[neighbor;xind+1 yind zind]; end
                if yind<N neighbor=[neighbor;xind yind+1 zind]; end
                if zind<P neighbor=[neighbor;xind yind zind+1]; end
            otherwise,
                error('Invalid number of neighbor. Choose from (6,18,26)');
        end

        switch neighbornum
            case {'18','26'} % if 18, include in-plane diagonal neighbors too.
                if xind>1
                    if yind>1 neighbor=[neighbor;xind-1 yind-1 zind]; end
                    if zind>1 neighbor=[neighbor;xind-1 yind zind-1]; end
                    if yind<N neighbor=[neighbor;xind-1 yind+1 zind]; end
                    if zind<P neighbor=[neighbor;xind-1 yind zind+1]; end
                end
                if xind<M
                    if yind>1 neighbor=[neighbor;xind+1 yind-1 zind]; end
                    if zind>1 neighbor=[neighbor;xind+1 yind zind-1]; end
                    if yind<N neighbor=[neighbor;xind+1 yind+1 zind]; end
                    if zind<P neighbor=[neighbor;xind+1 yind zind+1]; end
                end
                if yind>1 & zind>1 neighbor=[neighbor;xind yind-1 zind-1]; end
                if yind>1 & zind<P neighbor=[neighbor;xind yind-1 zind+1]; end
                if yind<N & zind>1 neighbor=[neighbor;xind yind+1 zind-1]; end
                if yind<N & zind<P neighbor=[neighbor;xind yind+1 zind+1]; end
        end

        switch neighbornum
            case '26', % if 26, include our-of-plane diagonal neighbors too.
                if xind>1
                    if yind>1
                        if zind>1 neighbor=[neighbor;xind-1 yind-1 zind-1]; end
                        if zind<P neighbor=[neighbor;xind-1 yind-1 zind+1]; end
                    end
                    if yind<N
                        if zind>1 neighbor=[neighbor;xind-1 yind+1 zind-1]; end
                        if zind<P neighbor=[neighbor;xind-1 yind+1 zind+1]; end
                    end
                end
                if xind<M
                    if yind>1
                        if zind>1 neighbor=[neighbor;xind+1 yind-1 zind-1]; end
                        if zind<P neighbor=[neighbor;xind+1 yind-1 zind+1]; end
                    end
                    if yind<N
                        if zind>1 neighbor=[neighbor;xind+1 yind+1 zind-1]; end
                        if zind<P neighbor=[neighbor;xind+1 yind+1 zind+1]; end
                    end
                end
        end
        
        
        for j=1:size(neighbor,1)
            rx=neighbor(j,1); ry=neighbor(j,2); rz=neighbor(j,3);
            if ~Y(rx,ry,rz)
                if abs(X(rx,ry,rz))>Tol
                    Y(rx,ry,rz) = 1;
                    pos_stack=[pos_stack;rx ry rz];
                end
            end
        end
    end
    
    if end_id==size(pos_stack,1) break; end
    start_id=end_id+1;
    end_id=size(pos_stack,1);

end

