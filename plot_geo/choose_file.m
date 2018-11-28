format long   %���ƾ���


%����ѡ��򿪵��ļ�
[filename, pathname] = uigetfile({'*.list;*.rsc','All Files';'*.*','All Files'},'MultiSelect','on');
if (length(filename)~=2)
    msgbox('ѡ����ļ�����������������ѡ��!','ȷ��','error');
else
    if ~isempty(strfind(filename(2),'.rsc'))    %�����.rsc�ļ���ִ�в���
        rsc=strcat(filename(2));
        rsc=rsc{1};
        frsc=fopen([pathname rsc],'rt');
        file_head=[];
        while ~feof(frsc)
            info=fgetl(frsc);
            for i=1:length(info)
                if double(info(i))>=48 && double(info(i))<=57   %��������һ������ʱǰ�潫�����ֲ����޳��������ַ���תΪdouble����
                    info(1:i-1)=[];
                    info=str2double(info);
                    break;
                end
            end
            file_head=[file_head;info];
        end
        fclose(frsc);
    end

    list=strcat(filename(1));
    list=list{1};
    flist=fopen([pathname list],'rt');
    cnt=1;
    while ~feof(flist)
        file_name=fgetl(flist);  %���ж�ȡ
        fid=fopen([pathname file_name],'rb');
        a=fread(fid,[file_head(1),file_head(2)],'float');
        a=a';
        subplot(2,3,cnt);
        img=imagesc([file_head(3),file_head(3)+file_head(4)*file_head(1)],[file_head(5),file_head(5)+file_head(6)*file_head(2)],a);
        set(gca,'XDir','normal');   %����x���������ҵ���
        set(gca,'YDir','normal');   %����y���������µ���
        daspect([1 1 1]);   %1:1��ʾ
        set(img,'alphadata',~isnan(a)); %���������������Ϊ��ɫ
        title(strrep(file_name,'_','-'));
        cnt=cnt+1;
        fclose(fid);
    end
    fclose(flist);

    %����colorbar�Ĵ�Сλ�ü���ֵ��Χ
    colorbar('position',[0.93 0.1 0.02 0.8]);
    caxis([min(min(a)),max(max(a))]);
end
    
    