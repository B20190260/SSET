function [Wx,t,f,xMean] = stft(x, fs, WindowOpt, Parameter, Mode)
%	------------------- ��ʱ����Ҷ�任 -------------------- 
%Input:
%       x:�ź�
%       fs:����Ƶ�ʣ�Hz��
%       WindowOpt:������ѡ�����
%           WindowOpt.s��(0.01) ��������ʼ�߶�
%           WindowOpt.type��(gauss) ����������
%       Parameter:Ƶ��ѡ�����
%           Parameter.L��(200) Ƶ�ʻ���
%           Parameter.fmin��(��С�ֱ���) ������СƵ��
%           Parameter.fmax��(�ο�˹��Ƶ��) �������Ƶ��
%       Mode:��ʱ����Ҷ��ʽѡ��
%Output:
%       Wx:��ʱ����Ҷ�任ϵ��(��һά��Ƶ�ƣ��ڶ�ά��ʱ��)
%       t��ʱ��
%       f��Ƶ��
%       xMean���ź�ƽ��ֵ
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: ���ܽܣ�2019/2/8��
%---------------------------------------------------------------------------------
%% Ԥ�����ź�
    N = length(x);          %�źų���
    t = (0:N-1)/fs;         %�ź�ʱ��
    [XPad, NUp, NL, ~] = padsignal(x, 'symmetric');    %�����ź�
    xMean = mean(XPad);     %���ֵ
    XPad = XPad-xMean;      %ȥ��ֵ
    XPad = hilbert(XPad);     %���ɽ����ź�
    xh = fft(XPad);           %��fft
%% Ĭ��ֵ�趨
    %Mode Ĭ��ֵ
    if nargin<5, Mode = 'modify'; end               
    %Parameter Ĭ��ֵ
    if nargin<4, Parameter = struct(); end            
    if ~isfield(Parameter, 'L'), Parameter.L = round(N/2); end
    if ~isfield(Parameter, 'fmin'), Parameter.fmin = 0; end
    if ~isfield(Parameter, 'fmax'), Parameter.fmax = fs/2; end
    %WindowOpt Ĭ��ֵ
    if nargin<3, WindowOpt = struct(); end            
    if ~isfield(WindowOpt, 's'), WindowOpt.s = 0.01; end
    if ~isfield(WindowOpt, 'type'), WindowOpt.type = 'gauss'; end
    %������ֵ
    s = WindowOpt.s; type = WindowOpt.type;
    L = Parameter.L; fmin = Parameter.fmin; fmax = Parameter.fmax;
%% ��ʱ����Ҷ����
    %Ƶ�Ʋ�������
    f = linspace(fmin, fmax, L);
    %������Ƶ����ʽ
    [gf,~] = windowf(s,type);
    %����ģ��Ƶ�ʵ�����
    wi = zeros(1, NUp);
    wi(1:NUp/2+1) = 2*pi*(0:NUp/2)*fs/NUp;
    wi(NUp/2+2:end) = 2*pi*(-NUp/2+1:-1)*fs/NUp;
    %��ʱ����Ҷϵ����⣨ʱ������Ƶ����ˣ�
    Wx = zeros(L, NUp);
    for ptr = 1:L
        gh = gf(wi-2*pi*f(ptr));
        gh = conj(gh);
        xcpsi = ifft(gh .* xh);
        Wx(ptr, :) = xcpsi;
    end
    %��ȡ��ʵ�ź�ʱƵ��ʾ
    Wx = Wx(:, NL+1:NL+length(x));
    %���ֶ�ʱ����Ҷ��ת��
    if strcmp(Mode, 'normal')
        for i = 1:L
            for j = 1:N
                Wx(i,j) = Wx(i,j)*exp(-1i*2*pi*f(i)*t(j));
            end
        end
    end
end