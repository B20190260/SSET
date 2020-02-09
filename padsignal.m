function [XPad, NUp, NL, NR] = padsignal(X, PadType)
%	------------------- �ź����� -------------------- 
%Input:
%       X:�ź�
%       PadType:��չ�źŵķ�����symmetric������replicate�����ƣ�
%Output:
%       XPad:��չ����ź�
%       NUp:��չ���źų���
%       NL:�����չ�󳤶�
%       NR:�Ҷ���չ�󳤶�
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: ���ܽܣ�2019/1/8��
%---------------------------------------------------------------------------------
    N = length(X);
    if iscolumn(X)
        X = X';
    end
    [NUp, NL, NR] = p2up(N);
    if strcmpi(PadType,'symmetric')
        Temp=[X flip(X)];               %�������ĺô��Ƿ�ֹԭ�źŵĳ��Ȳ�������������Ҫ����ĳ���
        XL = Temp(mod((0:NL-1),2*N)+1);
        XL =flip(XL);
        Temp=[flip(X) X];
        XR = Temp(mod((0:NR-1),2*N)+1);
    elseif strcmpi(PadType,'replicate')
        XL = X(1)*ones(NL,1);
        XR = X(end)*ones(NR,1);
    end
    XPad = [XL X XR];
end