function []=calLN()
%--------------------------------------------------------------------------
% This program is to calculate the Leveling NetWork adjustment
%The format of the data file：
%   number_of_knownPoint number_of_unknownPoint
%   info_of_point(the knownPoints in front,unknownPoints in after)
%   the height of knownPoints
%   startPoint endPoint difference_of_elevation length_of_measuring_section
%!!!Attention!!!:the data file not have blank lines
%--------------------------------------------------------------------------

%读取文件
[datafile,input_path]=uigetfile({'*.txt'});
inputpath=strcat(input_path,datafile);
f=fopen(inputpath,'rt');
cnt=0;  %记录数据的行数
startPoint=[];  %测段起点
endPoint=[];    %测段终点
h=[]; %测得的高差
s=[]; %测段长度
while ~feof(f)
    d=fgetl(f);
    cnt=cnt+1;
    switch cnt
        case 1
            %info为已知点和未知点的数量信息
            info=str2num(char(split(d,' ')));    %字符串按空格分隔转为元胞数组，并将元胞数组转为字符串数组，最后转为数字
        case 2
            point=split(d,' ');  %点名
            knownPoint=point(1:info(1));  %未知点
            unknownPoint=point(info(1)+1:length(point));  %已知点
        case 3
            height=str2num(char(split(d,' ')));  %高程
        otherwise
            temporary=char(split(d,' '));  %临时存放读取到的数据
            startPoint{cnt-3}=strtrim(temporary(1,:));
            endPoint{cnt-3}=strtrim(temporary(2,:));
            h=[h;str2num(temporary(3,:))];
            s=[s;str2num(temporary(4,:))];
    end
end
fclose(f);

%为起点终点点号添加数字索引
for i=1:cnt-3
    for j=1:length(point)
        if startPoint{i}==point{j}
            sindex(i)=j;
        end
        if endPoint{i}==point{j}
            eindex(i)=j;
        end
    end
end

%计算权阵
weight=1./s;
for i=1:length(weight)
    if weight(i)==inf
        weight(i)=0;
    end
end
P=diag(weight);

%计算近似高程
height(info(1)+1:info(1)+info(2))=0;    %将近似点高程初始化为0
B(cnt-3,length(unknownPoint))=0;      %系数项矩阵
for i=1:cnt-3
    %计算误差方程x的系数项
    for j=1:length(unknownPoint)
        if startPoint{i}==unknownPoint{j}
            B(i,sindex(i)-info(1))=-1;
        end
        if endPoint{i}==unknownPoint{j}
            B(i,eindex(i)-info(1))=1;
        end
    end
end

%计算近似高程
todo=[];
num=0;  %已计算的近似高程数
for i=1:cnt-3
    todo=[todo;i];
end
while num~=info(2)
    for i=1:length(unknownPoint)
        if height(info(1)+i)==0
            for j=1:length(todo)
                if sindex(todo(j))==i+info(1) && height(eindex(todo(j)))~=0
                    height(info(1)+i)=height(eindex(todo(j)))-h(todo(j));
                    num=num+1;
                    todo(j)=[];
                    break;
                elseif eindex(todo(j))==i+info(1) && height(sindex(todo(j)))~=0
                    height(info(1)+i)=height(sindex(todo(j)))+h(todo(j));
                    num=num+1;
                    todo(j)=[];
                    break;
                 end
            end
        end
    end
end

%计算L
L=[];
for i=1:cnt-3
    L=[L;height(eindex(i))-height(sindex(i))-h(i)];
end
L=-L;

%平差
N=B'*P*B;
W=B'*P*L;
x=inv(N)*W;
height(info(1)+1:end)=height(info(1)+1:end)+x;
V=(B*x-L);
h=h+V;
do=sqrt(V'*P*V/(cnt-3-info(1)));    %单位权中误差

%数据输出
[outputfile,output_pathname]=uiputfile({'*.txt','文本文件'});
outputpath=strcat(output_pathname,outputfile);
fprintf('数据已保存在%s\n',outputpath);
fid=fopen(outputpath,'wt');
fprintf(fid,'单位权中误差: %.4fmm\n',do);
fprintf(fid,'\n点号\t高程(m)\t高程改正数(m)\n');
for i=1:length(knownPoint)
    fprintf(fid,'  %s\t %.4f\n',point(i,:),height(i));
end
for i=length(knownPoint)+1:length(point)
    fprintf(fid,'  %s\t %.4f\t   %.4f\n',point(i,:),height(i),x(i-length(knownPoint)));
end
fprintf(fid,'\n起点\t终点\t未改正高差(m)\t高差改正数(mm)\t改正后高差(m)\n');
for i=1:cnt-3
    fprintf(fid,'  %s\t  %s\t %.4f\t\t%.4f\t\t%.4f\n',startPoint{i},endPoint{i},h(i)-V(i),V(i),h(i));
end
fclose(fid);
disp('文件输出完成');