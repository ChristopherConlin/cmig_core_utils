function s = mat2sparse(f)

s = struct();
s.dims = size(f);
s.ivec = find(f);
s.s = f(s.ivec);
