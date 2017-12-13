function [Hank,y_sol] = Hankel_ij(y1,y2,diff)
    N1 = length(y1);
    N2 = length(y2);
    N = N1 + N2;
    Np = diff;
    Nf = N + Np;
    Hank=zeros((Nf+mod(Nf,2))/2,(Nf+mod(Nf,2))/2,2);

    for k=1:2

        cvx_begin sdp
            variable y_star(Np,2)
            expression H((Nf+mod(Nf,2))/2,(Nf+mod(Nf,2))/2)
            for i=1:Nf/2
                for j=1:Nf/2
                    if j+i-1 <= N1
                        H(i,j) = y1(j+(i-1),k);
                    elseif j+i-1 > N1 + Np
                        H(i,j) = y2(j+(i-1)-N1-Np,k);
                    else
                        H(i,j) = y_star((j+(i-1)-N1),k);
                    end
                end
            end
            variable X((Nf+mod(Nf,2))/2,(Nf+mod(Nf,2))/2) symmetric
            variable Z((Nf+mod(Nf,2))/2,(Nf+mod(Nf,2))/2) symmetric

            minimize(trace(X) + trace(Z))
            [ X H; ...
            H' Z] >= 0
            Z >= 0;
            X >= 0;

        cvx_end
        
        Hank(:,:,k) = H;
        y_sol(:,k) = full(y_star(:,k));
    
    end
end