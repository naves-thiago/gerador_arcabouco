-- Gerador de módulos para programação modular

local str_util = require("str_util")
local io = io
local os = os
local string = string
local print = print
local ipairs = ipairs
local tostring = tostring
local assert = assert
local type = type
local table = table
local mod= {}
if setfenv then
   setfenv(1, mod) -- lua 5.1
else
   _ENV = mod -- lua 5.2
end

-- Arquivos
local f_code, f_header, f_test, f_script
local params = {}

-- Cria os handles dos arquivos
local function abrir_arquivos()
   f_code = io.open(params.arq_code, "w")
   if (f_code == nil) then
      return false
   end

   f_header = io.open(params.arq_head, "w")
   if (f_header == nil) then
      f_code:close()
      return false
   end

   if (arq_test) then
      f_test = io.open(params.arq_test, "w")
      if (f_test == nil) then
         f_code:close()
         f_header:close()
         return false
      end
   end

   if (arq_script) then
      f_script = io.open(params.arq_script, "w")
      if (f_script == nil) then
         f_code:close()
         f_header:close()
         f_test:close()
         return false
      end
   end

   return true
end

-- params: file, nome do arquivo, nome do modulo
local function imprimir_cabecalho(f, nome_arq, modulo)
   f:write("/**********************************************************************\n")
   f:write("*\n")
   f:write("*  $MCD Módulo de definição: Módulo "..modulo.."\n")
   f:write("*\n")
   f:write("*  Arquivo gerado:              "..nome_arq.."\n")
   f:write("*  Letras identificadoras:      "..params.id.."\n")
   f:write("*\n")
   f:write("*  Projeto: Disciplina INF 1301\n")
   f:write("*  Autores:\n")
   f:write("*           \n")
   f:write("*\n")
   f:write("*  $HA Histórico de evolução:\n")
   f:write("*     Versão  Autor    Data     Observações\n")
   f:write("*       1.00   ???   "..os.date("%d/%m/%Y").." Início do desenvolvimento\n")
   f:write("*\n")
   f:write("*  $ED Descrição do módulo\n")
   f:write("*     Descrição...\n")
   f:write("*\n")
   f:write("***********************************************************************/\n")
end

-- params: file, função
local function  imprimir_prototipo(f, fn)
   -- imrprime tipo de retorno
   if type(fn[3]) == "string" then
      f:write("   "..fn[3].." ")
   else
      f:write("   "..params.id.."_tpCondRet ")
   end

   f:write(str_util.camel_case(fn[1]).."( ")
   if (not fn[4]) or (#fn[4] == 0) then
      f:write("void )") -- nenhum parâmetro
   else
      -- Primeiro parâmetro sem vírgula antes
      f:write(fn[4][1][2].." "..fn[4][1][1])
      for p = 2,#fn[4] do
         -- fn[4][p] = {"Nome", "tipo", "descrição"}
         f:write(" , "..fn[4][p][2].." "..fn[4][p][1])
      end
      f:write(" )")
   end
end

-- params: file, tabela, tamanho da linha
local function imprimir_desc_params(f, t, lin_size)
   local max_len = 0

   assert(t)
   assert(lin_size)

   -- encontra max len
   for i,j in ipairs(t) do
--    j = {'Nome', 'Tipo', 'Descrição'}
      local len = #(j[1])

      if max_len < len then
         max_len = len
      end
   end

   local wrap = lin_size - max_len - 11

   for i,j in ipairs(t) do
      f:write("*     $P "..j[1]..string.rep(" ", max_len - #(j[1]) + 1))
      local desc = str_util.line_wrap_with_prefix(j[3], wrap, "  ")
      desc = "-"..desc:sub(2,#desc)
      f:write(desc)
   end
end


-- Cria o arquivo de header (assume f_header válido)
local function criar_header()
   local f = f_header
   local id = params.id
   local nome = str_util.remove_acentos(params.nome)
   local define = string.upper(nome:gsub(" ","_"))

   f:write("#if ! defined( "..define.."_ )\n")
   f:write("#define "..define.."_\n")
   imprimir_cabecalho(f, params.arq_head, params.nome)
   f:write("\n")
   f:write("\n")
   f:write("/***********************************************************************\n")
   f:write("*\n")
   f:write("*  $TC Tipo de dados: "..id.." Condições de retorno\n")
   f:write("*\n")
   f:write("*\n")
   f:write("***********************************************************************/\n")
   f:write("\n")
   f:write("   typedef enum {\n")
   f:write("\n")

   local cr
   for cr = 1,#params.cond_ret-1 do
      f:write("      "..id.."_CondRet"..params.cond_ret[cr][1].." = "..tostring(cr-1).." ,\n")
      f:write("          /* "..params.cond_ret[cr][2].." */\n")
      f:write("\n")
   end
-- não colocar vírgula no último
   cr = #params.cond_ret
   f:write("      "..id.."_CondRet"..params.cond_ret[cr][1].." = "..tostring(cr-1).."\n")
   f:write("          /* "..params.cond_ret[cr][2].." */\n")
   f:write("\n")

   f:write("   } "..id.."_tpCondRet ;\n")
   f:write("\n")
   f:write("\n")

   local i, fn
   for i,fn in ipairs(params.funcoes) do
      -- fn = {'Nome da função', 'Descrição', Retornos, Parâmetros, Privada}
      if not fn[5] then -- não é privada
         f:write("/***********************************************************************\n")
         f:write("*\n")
         f:write("*  $FC Função: "..id.." "..fn[1].."\n")
         f:write("*\n")
         f:write("*  $ED Descrição da função\n")
         f:write(str_util.line_wrap_with_prefix(fn[2], 65, "*     "))
         f:write("*\n")
         f:write("*  $EP Parâmetros\n")
         imprimir_desc_params(f, fn[4], 72)
         f:write("*\n")
         f:write("*  $FV Valor retornado\n")
         for j,ret in ipairs(fn[3]) do
            f:write("*     "..id.."_CondRet"..ret.."\n")
         end
         f:write("*\n")
         f:write("***********************************************************************/\n")
         f:write("\n")

         imprimir_prototipo(f, fn)
         f:write(" ;\n")
      end
   end

   f:flush()
   f:close()
end

-- Retorna uma tabela com as funções privadas do módulo
local function funcoes_privadas()
   local t = {}
   local i,fn
   for i,fn in ipairs(params.funcoes) do
      if fn[5] == true then
         table.insert(t, fn)
      end
   end

   return t
end

local function criar_code()
   local f = f_code
   local func_p = funcoes_privadas()

   imprimir_cabecalho(f, params.arq_code, params.nome)
   f:write("\n")
   f:write('#include   <stdio.h>\n')
   f:write('#include   <stdlib.h>\n')
   f:write('#include   "'..params.arq_head..'"\n')
   f:write("\n")

-- Protótipos das funções privadas / static
   if #func_p > 0 then
      f:write("/***** Protótipos das funções encapuladas no módulo *****/\n")
      f:write("\n")
   end

   local i,fn
   for i,fn in ipairs(func_p) do
      -- fn = {'Nome da função', 'Descrição', Retornos, Parâmetros, Privada}
      imprimir_prototipo(f, fn)
      f:write(" ;\n")
      f:write("\n")
   end

   f:write("\n")
   f:write("/*****  Código das funções exportadas pelo módulo  *****/\n")
   f:write("\n")


   f:flush()
   f:close()
end


-- Parâmetros:
-- nome: Nome do módulo
-- id: Nome abreviado / prefixo / namespace do módulo
-- testes: Se true, também será gerado um arquivo de teste (.c) e um script (.script) para o arcabouço
-- cond_ret: Lista de condições de retorno para o arcabouço que serão usadas nesse módulo
--          Cada elemento dessa tabela deve ser uma tabela no formato {'Nome da condição', 'Descrição'}
-- funcoes: Lista de funções do módulo
--          Cada elemento dessa tabela deve ser uma tabela no formato {'Nome da função', 'Descrição',
--          Retornos, Parâmetros, Privada} onde:
--          - Retornos é uma lista de nomes de condições de retorno, que devem pertencer à tabela condRet.
--            Se esse parâmetro for uma string em vez de uma tabela, essa string será usada como tipo
--            de retorno, em vez de tpCondRet.
--          - Parâmetros é uma lista contendo os parâmetros da função. Cada elemento dessa lista deve ser
--            uma tabela no formato {'Nome', 'Tipo', 'Descrição'}
--          - Privada: Se true, a função é declarada como static, o namespace é omitido, o protótipo é
--            colocado no início do .c e a função é omitida do .h e dos testes.
-- arq_code: Nome do arquivo .c do módulo.
-- arq_head: Nome do arquivo .h do módulo.
-- arq_test: Nome do arquivo .c de teste.
-- arq_script: Nome do arquivo de script de teste.
function criar_modulo(nome, id, testes, cond_ret, funcoes, arq_code, arq_head, arq_test, arq_script)
   params.nome = nome
   params.id = string.upper(id)
   params.cond_ret = cond_ret
   params.funcoes = funcoes
   params.testes = testes
   params.arq_code = arq_code
   params.arq_head = arq_head
   params.arq_test = arq_test
   params.arq_script = arq_script

   if not abrir_arquivos() then
      return
   end

   criar_header()
   criar_code()
end


return mod
