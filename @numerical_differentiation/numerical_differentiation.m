classdef numerical_differentiation < handle
%  Purpose:
%
%    Encapsulate the functions for numerical differentiation in the package
%    derivest by John D'Errico.
%
%  Input:
%
%    None
%
%  Output:
%
%    None
%
%  Reference:
%
%    http://www.mathworks.com/matlabcentral/fileexchange/13490
%    
%  Notes:
%
%    The gradest function has been updated to accept an optional argument 
%    for the type of differences that need to be used. 'central' is its 
%    default value, just like in the derivest function.
%
%  Author : Georgios Magkotsios
%  Version: January 2012
%
   methods
       function obj = numerical_differentiation
       end
   end

   methods
       [der,errest,finaldelta] = derivest(obj,fun,x0,varargin)
       [dd,err,finaldelta] = directionaldiff(obj,fun,x0,vec)
       [grad,err,finaldelta] = gradest(obj,fun,x0,varargin)
       [HD,err,finaldelta] = hessdiag(obj,fun,x0)
       [hess,err] = hessianest(obj,fun,x0)
       [jac,err] = jacobianest(obj,fun,x0)
   end

end