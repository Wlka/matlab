function []=calLN()
%--------------------------------------------------------------------------
% This program is to calculate the Leveling NetWork adjustment
%The format of the data file��
%   number_of_knownPoint number_of_unknownPoint
%   info_of_point(the knownPoints in front,unknownPoints in after)
%   the height of knownPoints
%   startPoint endPoint difference_of_elevation length_of_measuring_section
%!!!Attention!!!:the data file not have blank lines
%--------------------------------------------------------------------------

%��ȡ�ļ�
[datafile,input_path]=uigetfile({'*.txt'});
inputpath=strcat(input_path,datafile);
f=fopen(inputpath,'rt');
cnt=0;  %��¼���ݵ�����
startPoint=[];  %������
endPoint=[];    %����յ�
h=[]; %��õĸ߲�
s=[]; %��γ���
while ~feof(f)
    d=fgetl(f);
    cnt=cnt+1;
    switch cnt
        case 1
            %infoΪ��֪���δ֪���������Ϣ
            info=str2num(char(split(d,' ')));    %�ַ������ո�ָ�תΪԪ�����飬����Ԫ������תΪ�ַ������飬���תΪ����
        case 2
            point=split(d,' ');  %����
            knownPoint=point(1:info(1));  %δ֪��
            unknownPoint=point(info(1)+1:length(point));  %��֪��
        case 3
            height=str2num(char(split(d,' ')));  %�߳�
        otherwise
            temporary=char(split(d,' '));  %��ʱ��Ŷ�ȡ��������
            startPoint{cnt-3}=strtrim(temporary(1,:));
            endPoint{cnt-3}=strtrim(temporary(2,:));
            h=[h;str2num(temporary(3,:))];
            s=[s;str2num(temporary(4,:))];
    end
end
fclose(f);

%Ϊ����յ��������������
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

%����Ȩ��
weight=1./s;
for i=1:length(weight)
    if weight(i)==inf
        weight(i)=0;
    end
end
P=diag(weight);

%������Ƹ߳�
height(info(1)+1:info(1)+info(2))=0;    %�����Ƶ�̳߳�ʼ��Ϊ0
B(cnt-3,length(unknownPoint))=0;      %ϵ�������
for i=1:cnt-3
    %��������x��ϵ����
    for j=1:length(unknownPoint)
        if startPoint{i}==unknownPoint{j}
            B(i,sindex(i)-info(1))=-1;
        end
        if endPoint{i}==unknownPoint{j}
            B(i,eindex(i)-info(1))=1;
        end
    end
end

%������Ƹ߳�
todo=[];
num=0;  %�Ѽ���Ľ��Ƹ߳���
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

%����L
L=[];
for i=1:cnt-3
    L=[L;height(eindex(i))-height(sindex(i))-h(i)];
end
L=-L;

%ƽ��
N=B'*P*B;
W=B'*P*L;
x=inv(N)*W;
height(info(1)+1:end)=height(info(1)+1:end)+x;
V=(B*x-L);
h=h+V;
do=sqrt(V'*P*V/(cnt-3-info(1)));    %��λȨ�����

%�������
[outputfile,output_pathname]=uiputfile({'*.txt','�ı��ļ�'});
outputpath=strcat(output_pathname,outputfile);
fprintf('�����ѱ�����%s\n',outputpath);
fid=fopen(outputpath,'wt');
fprintf(fid,'��λȨ�����: %.4fmm\n',do);
fprintf(fid,'\n���\t�߳�(m)\t�̸߳�����(m)\n');
for i=1:length(knownPoint)
    fprintf(fid,'  %s\t %.4f\n',point(i,:),height(i));
end
for i=length(knownPoint)+1:length(point)
    fprintf(fid,'  %s\t %.4f\t   %.4f\n',point(i,:),height(i),x(i-length(knownPoint)));
end
fprintf(fid,'\n���\t�յ�\tδ�����߲�(m)\t�߲������(mm)\t������߲�(m)\n');
for i=1:cnt-3
    fprintf(fid,'  %s\t  %s\t %.4f\t\t%.4f\t\t%.4f\n',startPoint{i},endPoint{i},h(i)-V(i),V(i),h(i));
end
fclose(fid);
disp('�ļ�������');