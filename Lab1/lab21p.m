Rx=[9 -6 2; -6 9 -6; 2 -6 9] + eye(3)*0.5;
rdx0=[1 0 0]';
rdx1=[-2 1 0]';
rdx2=[2 -2 1]';
rdx3=[0 2 -2]';
rdx4=[0 0 2]';

wo0=Rx\rdx0;
wo1=Rx\rdx1;
wo2=Rx\rdx2;
wo3=Rx\rdx3;
wo4=Rx\rdx4;

C=[1 -2 2];

N=2^12;
Fs=1;

f=(0:N-1)/N*Fs/2;
Hchannel=freqz(C,1,f,Fs);
H0=freqz(wo0,1,f,Fs);
H1=freqz(wo1,1,f,Fs);
H2=freqz(wo2,1,f,Fs);
H3=freqz(wo3,1,f,Fs);
H4=freqz(wo4,1,f,Fs);

figure
 plot(f,20*log10(abs(Hchannel)),'b'); hold on
 plot(f,20*log10(abs(H0)),'r--'); hold on
 plot(f,20*log10(abs(H1)),'y:'); hold on
 plot(f,20*log10(abs(H2)),'m-.'); hold on
 plot(f,20*log10(abs(H3)),'c--'); hold on
 plot(f,20*log10(abs(H4)),'k'); hold on
 zoom on
 grid on
 set(findobj('Type','Line'),'LineWidth',2);
legend('channel','equalizer, D=0','equalizer, D=1','equalizer, D=2','equalizer, D=3','equalizer, D=4',4);
 xlabel('frequency');
 ylabel('magniture (dB)');
 print -deps2c lab21.eps


Jmin0=1-wo0'*rdx0
Jmin1=1-wo1'*rdx1
Jmin2=1-wo2'*rdx2
Jmin3=1-wo3'*rdx3
Jmin4=1-wo4'*rdx4



