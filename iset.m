function b = iset(Ex,ExPosition, xMean,q,Rep,Mode,WindowOpt) 
%	------------------- ��ʱ����Ҷ��任 -------------------- 
%Input:
%       Wx:��ʱ����Ҷ�任ϵ��
%       xMean:���任ʱȥ����ƽ��ֵ
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
%       b:�ع��ź�
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: ���ܽܣ�2019/2/8��
%---------------------------------------------------------------------------------
%% ��任
    %�ع�
    s = WindowOpt.s;
    type = WindowOpt.type;
    if strcmp(Mode, '1Ord')
        %��ʱ������
        [gf,~] = windowf(s,type);
        %����g(0)
        g0 = gf(0);
        if(g0 == 0)
            error('window must be non-zero and continuous at 0 !');
        end
        Ex = Ex / g0;
    elseif strcmp(Mode, '2Ord')
        M = sqrt(-q+1/(s^2));
        N = exp(-0.5*(-Rep./M).^2);
        for i =1:length(Ex)
            Ex(i) = Ex(i)/pi^(1/4)*sqrt(s)/sqrt(2)*M(ExPosition(i),i)*N(ExPosition(i),i);
        end
    end
    b = real(Ex);
    % ���ƽ��ֵ
    b = b+xMean;
end