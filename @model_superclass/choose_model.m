function obj_out = choose_model(obj,vec1,vec2,mat1,mat2,mat3,use_fed_data)
%  Purpose:
%
%    Choose which model to implement with the "switch logic", since
%    polymorphism in MATLAB is not recommended.
%
%  Input:
%
%    The typical model input, which includes 2 vectors and 3 matrices, and
%    the flag for data input source (FED/Fama-Bliss).
%
%  Output:
%
%    Model object
%
%  Author : Georgios Magkotsios
%  Version: November 2011
%

    if     strcmpi(obj.model_name(1:4),'DNSS')
        obj_out = DNSS_model(obj.model_name,vec1,vec2,  ...
                             mat1,mat2,mat3,use_fed_data);
    elseif strcmpi(obj.model_name(1:4),'DGNS')
        obj_out = DGNS_model(obj.model_name,vec1,vec2,  ...
                             mat1,mat2,mat3,use_fed_data);
    elseif strcmpi(obj.model_name(1:3),'DNS')
        obj_out = DNS_model(obj.model_name,vec1,vec2,   ...
                            mat1,mat2,mat3,use_fed_data);
    elseif strcmpi(obj.model_name(1:4),'AFNS')
        obj_out = AFNS_model(obj.model_name,vec1,vec2,  ...
                             mat1,mat2,mat3,use_fed_data);
    elseif strcmpi(obj.model_name(1:5),'AFGNS')
        obj_out = AFGNS_model(obj.model_name,vec1,vec2, ...
                              mat1,mat2,mat3,use_fed_data);
    else
        error('Improper value for model choice.');
    end

end