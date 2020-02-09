function [Tx,t,f,xMean,InstantFreq,q,Rep] = sset(x , fs,  WindowOpt, Parameter, Mode)
%## If you use this code for your research, please cite our paper:
%## Xiaotong Tu, Zhoujie He, Yue Hu and Fucai Li, The Second Order Synchroextracting Transform with Application to Bearing Fault Diagnosis under Variable Speed Conditions, Asia Pacific Conference of the Prognostics and Health Management Society 2019, Beijing, China.
%## Should you have any further questions or requirements in this respect, please feel free to contact me.��tormiier@gmail.com��
%	------------------- ͬ��ѹ�� -------------------- 
%Input:
%       Wx:С���任ϵ��
%       InstantFreq:���任ʱȥ����ƽ��ֵ
%       fs:����Ƶ�ʣ�Hz��
%       WindowOpt:������ѡ�����
%           WindowOpt.s��(0.01) ��������ʼ�߶�
%           WindowOpt.f0��(0) ��������ʼ����Ƶ��
%           WindowOpt.type��(gauss) ����������
%       Parameter:Ƶ��ѡ�����
%           Parameter.L��(200) Ƶ�ʻ��ָ���
%           Parameter.fmin��(��С�ֱ���) ������СƵ��
%           Parameter.fmax��(�ο�˹��Ƶ��) �������Ƶ��
%Output:
%       Tx:SSTϵ��
%       fm:ѹ�����Ƶ�ʣ�Hz��
%% Ԥ�����ź�
    N = length(x);
%% ������ֵ
    s = WindowOpt.s; type = WindowOpt.type;
    L = Parameter.L; fmin = Parameter.fmin; fmax = Parameter.fmax;
    gamma = sqrt(eps); 
%% SST����
    %STFT����
    [Wx,t,f,xMean] = stft(x, fs, WindowOpt, Parameter, 'modify');
    %˲ʱƵ�ʼ���
    if strcmp(Mode, '1Ord')
        WindowOpt.type = '1ord(t)_gauss';
        [dWx,~,~,~] = stft(x, fs, WindowOpt, Parameter, 'modify');
        InstantFreq = -imag(dWx./Wx)/2/pi;
        for ptr = 1:L
            InstantFreq(ptr,:) = InstantFreq(ptr,:) + f(ptr);
        end
        InstantFreq( abs(Wx) < gamma ) = Inf;
        q = inf;
        Rep = inf;
    elseif strcmp(Mode, '2Ord')
        WindowOpt.type = '1ord(t)_gauss';
        [dWx,~,~,~] = stft(x, fs, WindowOpt, Parameter, 'modify');
        WindowOpt.type = '2ord(t)_gauss';
        [ddWx,~,~,~] = stft(x, fs, WindowOpt, Parameter, 'modify');
        WindowOpt.type = 't*gauss';
        [tWx,~,~,~] = stft(x, fs, WindowOpt, Parameter, 'modify');
        WindowOpt.type = 't*1ord(t)_gauss';
        [tdWx,~,~,~] = stft(x, fs, WindowOpt, Parameter, 'modify');
        Denominator = tdWx.*Wx-tWx.*dWx;
        Numerator = ddWx.*tWx-dWx.*tdWx;
        Numerator2 = dWx.*dWx-ddWx.*Wx;
        q = Numerator2./Denominator;%denotes:q
        p = Numerator./Denominator;%denotes:qw+p-jw
        for ptr = 1:L
            p(ptr,:) = p(ptr,:) + 1i*f(ptr)*2*pi;
        end
        Rep = real(p);%denotes:-(t-t0)/s^2
        InstantFreq = imag(p)/2/pi;%denotes:b+ct
        InstantFreq( abs(Denominator) < gamma ) = Inf;
    else
        error('Unknown SST Mode: %s', Mode);
    end
    %Ƶ�ʲ�ּ���
    df = f(2)-f(1);
    %ͬ��ѹ��
    Wx(isinf(InstantFreq)) = 0;
    Tx = zeros(L,N);
    for b=1:N
       for prt=1:L
            k = min(max(1 + round((InstantFreq(prt,b)-fmin)/df),1),L);
            if(prt == k)
                Tx(prt, b) = Wx(prt, b);
            end
        end
    end
end
