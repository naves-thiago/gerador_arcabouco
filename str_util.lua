local string = string
local print = print
local ipairs = ipairs
local pairs = pairs
local table = table
local mod= {}

if setfenv then
   setfenv(1, mod) -- lua 5.1
else
   _ENV = mod -- lua 5.2
end

-- Divide uma string s em várias de tamanho máximo n cada
function line_wrap(s, n)
   local p = 0  -- string position
   local l = 0  -- current line length
   local f = 0  -- find result
   local br = 0 -- line break
   local lines = {}
   local b = false --break
   local wrap = false -- force wrap on a \n

   br = s:find("\n")
   while p ~= nil do
      f = s:find(" ", p + 1)
      if br ~= nil then
         if br < p then
            br = p
         end
      end

      if f == nil then
         if br then
            f = br
         else
            f = #s
            b = true
         end
      else
         if br and (f > br) then
            f = br
            br = s:find("\n", br + 1)
            wrap = true
         end
      end

      if wrap then
         if p == 0 then
            table.insert(lines, s:sub(1, f-1))
         else
            if s:sub(p-l, p-l) == " " or
               s:sub(p-l, p-l) == "\n" then
               p = p +1
            end
            table.insert(lines, s:sub(p-l, f-1))
         end
         wrap = false
         p = f
         l = 0
      else
         if (l + f - p) <= n then
            l = l + f - p -- still fits in the line
         else
            if p == 0 then
               p = f
               l = f-1
            end
            if s:sub(p-l, p-l) == " " or
               s:sub(p-l, p-l) == "\n" then
               table.insert(lines, s:sub(p-l+1, p-1))
            else
               table.insert(lines, s:sub(p-l, p-1))
            end
            l = f-p
         end

         p = f
         if b then
            if l > 0 then
               p = p + 1
               if s:sub(p-l, p-l) == " " or
                  s:sub(p-l, p-l) == "\n" then
                  table.insert(lines, s:sub(p-l+1, f))
               else
                  table.insert(lines, s:sub(p-l, f))
               end
            end
            break
         end
      end
   end

   return lines
end

function line_wrap_with_prefix(s, n, prefix)
   local out = ""
   local t = line_wrap(s,n)
   for i, j in ipairs(t) do
      out = out .. prefix .. j .. "\n"
   end

   return out
end

function remove_acentos(s)
   local t={}
   t["á"] = "a"
   t["é"] = "e"
   t["í"] = "i"
   t["ó"] = "o"
   t["ú"] = "u"
   t["ã"] = "a"
   t["ç"] = "c"
   t["à"] = "a"
   t["è"] = "e"
   t["ì"] = "i"
   t["ò"] = "o"
   t["ù"] = "u"
   t["Á"] = "A"
   t["É"] = "E"
   t["Í"] = "I"
   t["Ó"] = "O"
   t["Ú"] = "U"
   t["Ã"] = "A"
   t["Ç"] = "C"
   t["À"] = "A"
   t["È"] = "E"
   t["Ì"] = "I"
   t["Ò"] = "O"
   t["Ù"] = "U"

   for i,j in pairs(t) do
      s = s:gsub(i,j)
   end

   return s
end

-- Remove acentos e formata a string em camel case
function camel_case(s)
   s = remove_acentos(s)
   local function fw(s)
      if (s) then
         return string.upper(s:sub(1,1)) .. string.lower(s:sub(2, #s))
      end
      return nil
   end

   s = s:gsub("(%w+)", fw)
   s = s:gsub(" ", "")
   return s
end

-- Cria uma cópia do vetor adicionando espaços à direita para igualar os tamanhos
-- O vetor v será iterado com ipairs()
-- Se o parâmetro index for utilizado, serão considerados os elementos v[i][index]
-- em vez de v[i], para o caso de v ser um vetor de tabelas
function right_padding_i(v, index)
   if not v then
      return nil
   end

   local out = {}
   local max = 0
   local i, s
   for i, s in ipairs(v) do
      if index then
         if max < #(s[index]) then
            max = #(s[index])
         end
      else
         if max < #s then
            max = #s
         end
      end
   end

   for i, s in ipairs(v) do
      if index then
         local k,v
         -- Copy table values and create the string at index
         out[i] = {}
         for k, v in pairs(s) do
            if k ~= index then
               out[i][k] = v
            else
               out[i][k] = v..string.rep(" ", max - #v)
            end
         end
      else -- Not a table, just create the new string
         out[i] = s..string.rep(" ", max - #s)
      end
   end

   return out
end

return mod
