function [Hank_i,Hank_j] = Hankel_i(y1,y2)
    N1 = length(y1);
    N2 = length(y2);
    Hank_i=zeros(N1/2,N1/2,2);
    Hank_j=zeros(N2/2,N2/2,2);
    

    for k=1:2
        H_i = zeros(N1/2,N1/2);
        H_j = zeros(N2/2,N2/2);
        for i=1:N1/2
            for j=1:N1/2
                H_i(i,j) = y1(j+(i-1),k);
            end
        end
        for i=1:N2/2
            for j=1:N2/2
                H_j(i,j) = y2(j+(i-1),k);
            end
        end
        Hank_i(:,:,k) = H_i;
        Hank_j(:,:,k) = H_j;
    end
end