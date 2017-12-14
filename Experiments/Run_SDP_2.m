clear all
sigma = 2;
subdirs = dir(pwd);
subdirs(~[subdirs.isdir]) = [];
tf = ismember( {subdirs.name}, {'.', '..'});
subdirs(tf) = [];
numberOfFolders = length(subdirs);
for n = 1: numberOfFolders
    thissubdir = subdirs(n).name;
    
        % Select a single testcase
        if strcmp(thissubdir,'5_obj')==1

    subdirpath = [pwd '\' thissubdir];   
    subsubdirs = dir(subdirpath);
    subsubdirs(~[subsubdirs.isdir]) = [];
    tf = ismember( {subsubdirs.name}, {'.', '..'});
    subsubdirs(tf) = [];
    numberOfSubFolders = length(subsubdirs);
    for m = 1: numberOfSubFolders
        thissubsubdir = subsubdirs(m).name;
        
        % Select a single testcase
%         if strcmp(thissubsubdir,'csv_3_1')==1
        
        subsubdirpath = [subdirpath '\' thissubsubdir];  
        files = dir([subsubdirpath '\alpha*.csv']);
        max_idx = 0;
        for file = files'
            filedir = strcat(subsubdirpath,'\',file.name);
            M = csvread(filedir);
            y1 = M(2:3,2:end);
            y1_pos = M(4,2:3);
            y2 = M(5:6,2:end);
            y2_pos = M(7,2:3);
            diff = M(8,2);
            idx_1 = M(9,2);
            idx_2 = M(9,3);
            max_idx = max(max_idx,max(idx_1,idx_2));
            y1( :, ~any(y1,1) ) = [];  %columns
            y1 = y1';
            y2( :, ~any(y2,1) ) = [];  %columns
            y2 = y2';
            N1 = length(y1);
            N2 = length(y2);
            if mod(N2,2) == 1
                y2 = y2(1:end-1,:);
                N2 = length(y2);
            end
            if mod(N1,2) == 1
                y1 = y1(2:end,:);
                N1 = length(y1);
            end
            [Hanki,Hankj] = Hankel_i(y1,y2);
            Sxi = svd(Hanki(:,:,1));
            Syi = svd(Hanki(:,:,2));
            Sxj = svd(Hankj(:,:,1));
            Syj = svd(Hankj(:,:,2));
            Hname = [subsubdirpath '\Hank_' num2str(idx_1) '_' num2str(idx_2) '.mat'];
            Yname = [subsubdirpath '\y_star_' num2str(idx_1) '_' num2str(idx_2) '.csv'];
            try
                load(Hname)
            catch
                [Hankij,y_star] = Hankel_ij(y1,y2,diff);
                save(Hname, 'Hankij','y_star')
                csvwrite(Yname,y_star)
            end
            Sxij = svd(Hankij(:,:,1));
            Syij = svd(Hankij(:,:,2));
            Simil_x = (sum(Sxi > sigma) + sum(Sxj > sigma))/(sum(Sxij > sigma)) - 0.99;
            Simil_y = (sum(Syi > sigma) + sum(Syj > sigma))/(sum(Syij > sigma)) - 0.99;
            Simil(idx_1+1,idx_2+1) = Simil_x + Simil_y;
            SimilT_x = (rank(Hanki(:,:,1)) + rank(Hankj(:,:,1)))/(rank(Hankij(:,:,1))) - 0.99;
            SimilT_y = (rank(Hanki(:,:,2)) + rank(Hankj(:,:,2)))/(rank(Hankij(:,:,2))) - 0.99;
            SimilT(idx_1+1,idx_2+1) = SimilT_x + SimilT_y;
        end
        try
            Simil(Simil == 0) = -1000;
            SimilT(SimilT == 0) = -1000;
            if size(Simil,1) == 1
                Simil = Simil + 0.01 - min(Simil(Simil~=-1000));
                SimilT = SimilT + 0.01 - min(SimilT(SimilT~=-1000));
            else
                Simil = Simil + 0.01 - min((max(Simil)~=-1000).*max(Simil));
                SimilT = SimilT + 0.01 - min((max(SimilT)~=-1000).*max(SimilT));
            end
%             csvwrite([subsubdirpath '\Pij_' num2str(sigma) '.csv'],Simil)
%             csvwrite([subsubdirpath '\Tij_' num2str(sigma) '.csv'],SimilT)
            clear Simil SimilT
        catch
            disp(thissubsubdir)
        end
        end
    end
%         end
end