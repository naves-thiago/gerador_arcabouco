module(..., package.seeall)

-- Divide uma string s em várias de tamanho máximo n cada
function line_wrap(s, n)
   local p = 0  -- string position
   local l = 0  -- current line length
   local f = 0  -- find result
   local br = 0 -- line break
   local lines = {}
   local b = false --break

   while p ~= nil do
      f = s:find(" ", p + 1)
      if f == nil then
         f = #s
         b = true
      end
      if (l + f - p) <= n then
         l = l + f - p -- still fits in the line
      else
         if p > 0 then
            if s:sub(p-l, p-l) == " " then
               table.insert(lines, s:sub(p-l+1, p-1))
            else
               table.insert(lines, s:sub(p-l, p-1))
            end
         end
         l = f-p
      end

      p = f
      if b then
         if l > 0 then
            p = p + 1
            if s:sub(p-l, p-l) == " " then
               table.insert(lines, s:sub(p-l+1, f))
            else
               table.insert(lines, s:sub(p-l, f))
            end
         end
         break
      end

   end

   return lines
end

function line_wrap_with_prefix(s, n, prefix)
   local s = ""
   local t = line_wrap(s,n)
   for i, j in ipairs(t) do
      s = s .. prefix .. j .. "\n"
   end

   return s
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
