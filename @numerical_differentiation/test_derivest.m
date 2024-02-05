function res = derivest_test(x,param1,param2)
   vec = [x(5) x(6)]';
   mat = [x(1) x(2); x(3) x(4)];
   res = param1*log(abs(det(mat))) + param2*vec'*mat*vec;
end