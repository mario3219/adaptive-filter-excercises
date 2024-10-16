figure('Position',[10 400 350 415]);
figure('Position',[375 400 430 415]);
figure('Position',[820 400 320 415]);

figure(1)
uicontrol(gcf,...
'Style','text',...
'Position',[10 390 220 20],...
'String','Channel equalization 1');

uicontrol(gcf,...
'Style','text',...
'Position',[10 360 150 20],...
'String','edge frequency [rel] =');
fg=uicontrol(gcf,...
'Style','edit',...
'Position',[165 360 30 20],...
'String','.2');
uicontrol(gcf,...
'Style','text',...
'Position',[205 360 60 20],...
'String','order =');
ordn=uicontrol(gcf,...
'Style','edit',...
'Position',[270 360 30 20],...
'String','10');
uicontrol(gcf,...
'Style','text',...
'Position',[10 330 50 20],...
'String','SB-att.=');
sniv=uicontrol(gcf,...
'Style','edit',...
'Position',[65 330 30 20],...
'String','.3');
kanal=uicontrol(gcf,...
'Style','pushbutton',...
'Position',[105 325 70 30],...
'String','Channel',...
'Value',0,...
'Callback',[...
'f=str2num(get(fg,''String''));',...
'K=str2num(get(ordn,''String''));',...
'sn=str2num(get(sniv,''String''));',...
'fax=[0:.1:1];',...
'Mag=[ones(1,round(f*2*11)) sn*ones(1,11-round(f*2*11))];',...
'h=fir2(K,fax,Mag);',...
'visa1(h);']);

uicontrol(gcf,...
'Style','text',...
'Position',[10 290 130 20],...
'String','symbol interval [samples] =');
inte=uicontrol(gcf,...
'Style','text',...
'Position',[145 290 30 20],...
'String','5');
uicontrol(gcf,...
'Style','text',...
'Position',[185 290 70 20],...
'String','window =');
sigint=uicontrol(gcf,...
'Style','edit',...
'Position',[260 290 30 20],...
'String','30');
inteval=uicontrol(gcf,...
'Style','slider',...
'Min',1,...
'Max',10,...
'Value',5,...
'Position',[10 265 170 20],...
'Callback',[...
'figure(2);',...
'N=round(get(inteval,''Value''));',...
'set(inte,''String'',num2str(N));']);

uicontrol(gcf,...
'Style','text',...
'Position',[10 240 70 20],...
'String','noise variance =');
vari=uicontrol(gcf,...
'Style','edit',...
'Position',[85 240 40 20],...
'String','.001');

uicontrol(gcf,...
'Style','text',...
'Position',[10 200 30 20],...
'String','mu=');
adk=uicontrol(gcf,...
'Style','text',...
'Position',[45 200 30 20],...
'String','.5');
adkonst=uicontrol(gcf,...
'Style','slider',...
'Min',0,...
'Max',3,...
'Value',.5,...
'Position',[80 200 170 20],...
'Callback',[...
'figure(2);',...
'mu=get(adkonst,''Value'');',...
'set(adk,''String'',num2str(mu));']);

uicontrol(gcf,...
'Style','text',...
'Position',[10 170 60 20],...
'String','equ.-order =');
adordn=uicontrol(gcf,...
'Style','edit',...
'Position',[75 170 30 20],...
'String','10');

uicontrol(gcf,...
'Style','text',...
'Position',[115 170 70 20],...
'String','update =');
udati=uicontrol(gcf,...
'Style','edit',...
'Position',[190 170 30 20],...
'String','6');

uicontrol(gcf,...
'Style','text',...
'Position',[10 140 50 20],...
'String','delay=');
delej=uicontrol(gcf,...
'Style','edit',...
'Position',[65 140 30 20],...
'String','10');

uicontrol(gcf,...
'Style','pushbutton',...
'Position',[10 100 50 25],...
'String','START',...
'Callback',[...
'q=length(h);',...
'p=str2num(get(adordn,''String''));',...
'br=str2num(get(vari,''String''));',...
'S=str2num(get(udati,''String''));',...
'del=str2num(get(delej,''String''));',...
'M=str2num(get(sigint,''String''));',...
'w=zeros(1,p);',...
'x=zeros(M,1);',...
'y=zeros(M,1);',...
'xh=zeros(M,1);',...
't=1;',...
'set(stop,''Value'',0);',...
'st=0;',...
'while st==0;',...
'  N=round(get(inteval,''Value''));',...
'  mu=get(adkonst,''Value'');',...
'  x=[0; x(1:length(x)-1)];',...
'  if mod(t,N)==0;',...
'    x(1)=2*round(rand)-1;',...
'  end;',...
'  y(2:length(y))=y(1:length(y)-1);',...
'  y(1)=h*x(1:q)+sqrt(br)*randn;',...
'  xh(2:M)=xh(1:M-1);',...
'  xh(1)=w*y(1:p);',...
'  d=x(1+del);',...
'  w=w+mu*( d-xh(1) )*rot90(y(1:p));',...
'  if mod(t,S)==0;',...
'    visa1(h);',...
'    visa2(w,x,y,xh,p);',...
'    pause(.1);',...
'  end;',...
'  t=t+1;',...
'  st=get(stop,''Value'');',...
'end;';]);

stop=uicontrol(gcf,...
'Style','checkbox',...
'Position',[70 100 60 25],...
'Value',0,...
'String','STOP',...
'Callback',[...
'figure(3);',...
'subplot(222);',...
'set(stop,''Value'',1);']);

uicontrol(gcf,...
'Style','pushbutton',...
'Position',[140 100 60 25],...
'Value',0,...
'String','Inverse',...
'Callback',[...
'visai1(h);']);

uicontrol(gcf,...
'Style','pushbutton',...
'Position',[210 100 60 25],...
'Value',0,...
'String','Wiener',...
'Callback',[...
'N=round(get(inteval,''Value''));',...
'br=str2num(get(vari,''String''));',...
'visaw1(h,N,br);']);

uicontrol(figure(1),...
'Style','pushbutton',...
'String','EXIT',...
'Position',[265 40 70 30],...
'Callback',[...
'close;',...
'close;',...
'close;']);

