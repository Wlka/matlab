format long   %控制精度


%自行选择打开的文件
[filename, pathname] = uigetfile({'*.list;*.rsc','All Files';'*.*','All Files'},'MultiSelect','on');
if (length(filename)~=2)
    msgbox('选择的文件数量不够，请重新选择!','确认','error');
else
    if ~isempty(strfind(filename(2),'.rsc'))    %如果是.rsc文件，执行步骤
        rsc=strcat(filename(2));
        rsc=rsc{1};
        frsc=fopen([pathname rsc],'rt');
        file_head=[];
        while ~feof(frsc)
            info=fgetl(frsc);
            for i=1:length(info)
                if double(info(i))>=48 && double(info(i))<=57   %当遇到第一个数字时前面将非数字部分剔除，并将字符串转为double类型
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
        file_name=fgetl(flist);  %逐行读取
        fid=fopen([pathname file_name],'rb');
        a=fread(fid,[file_head(1),file_head(2)],'float');
        a=a';
        subplot(2,3,cnt);
        img=imagesc([file_head(3),file_head(3)+file_head(4)*file_head(1)],[file_head(5),file_head(5)+file_head(6)*file_head(2)],a);
        set(gca,'XDir','normal');   %设置x轴自左至右递增
        set(gca,'YDir','normal');   %设置y轴自上至下递增
        daspect([1 1 1]);   %1:1显示
        set(img,'alphadata',~isnan(a)); %将非数字数据填充为白色
        title(strrep(file_name,'_','-'));
        cnt=cnt+1;
        fclose(fid);
    end
    fclose(flist);

    %设置colorbar的大小位置及数值范围
    colorbar('position',[0.93 0.1 0.02 0.8]);
    caxis([min(min(a)),max(max(a))]);
end
    
    