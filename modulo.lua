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

   if (params.arq_test) then
      f_test = io.open(params.arq_test, "w")
      if (f_test == nil) then
         f_code:close()
         f_header:close()
         return false
      end
   end

   --[[
   if (params.arq_script) then
      f_script = io.open(params.arq_script, "w")
      if (f_script == nil) then
         f_code:close()
         f_header:close()
         f_test:close()
         return false
      end
   end
--]]

   return true
end

-- Cria uma string com as iniciais do autor
-- params: nome do autor
function iniciais_autor(nome)
   assert(type(nome) == "string")
   local ret = nome:sub(1,1)
   local p = nome:find(" ")

   while p and p < #nome do
      ret = ret .. nome:sub(p+1, p+1)
      p = nome:find(" ", p+1)
   end

   return string.lower(ret)
end

-- params: file, nome do arquivo, nome do modulo
local function imprimir_cabecalho(f, nome_arq, modulo)
   local autores = params.autores or {}
   local aut = "???"

   if autores[1] then
      aut = iniciais_autor(autores[1])
      local i
      for i=2, #autores do
         aut = aut .. ", " .. iniciais_autor(autores[i])
      end
   end

   f:write("/**********************************************************************\n")
   f:write("*\n")
   f:write("*  $MCD Módulo de definição: Módulo "..modulo.."\n")
   f:write("*\n")
   f:write("*  Arquivo gerado:              "..nome_arq.."\n")
   f:write("*  Letras identificadoras:      "..params.id.."\n")
   f:write("*\n")
   f:write("*  Projeto: Disciplina INF 1301\n")
   if #autores == 0 then
      f:write("*  Autores:\n")
   else
      if #autores == 1 then
         f:write("*  Autor: " .. iniciais_autor(autores[1]) .. " - " .. autores[1] .. "\n")
      else
         f:write("*  Autores: " .. iniciais_autor(autores[1]) .. " - " .. autores[1] .. "\n")
      end
   end

   local i
   for i=2, #autores do
      f:write("*           " .. iniciais_autor(autores[i]) .. " - " .. autores[i] .. "\n")
   end

   f:write("*\n")
   f:write("*  $HA Histórico de evolução:\n")
   if #aut <= 5 then
      f:write("*     Versão  Autor    Data     Observações\n")
   else
      f:write("*     Versão  Autor"..string.rep(" ", #aut -4).."    Data     Observações\n")
   end
   f:write("*       1.00  "..aut.."   "..os.date("%d/%m/%Y").." Início do desenvolvimento\n")
   f:write("*\n")
   f:write("*  $ED Descrição do módulo\n")
   f:write("*     Descrição...\n")
   f:write("*\n")
   f:write("***********************************************************************/\n")
end

-- params: file, função
local function imprimir_prototipo(f, fn, id)
   -- imrprime tipo de retorno
   if type(fn.retornos) == "string" then
      f:write("   "..fn.retornos.." ")
   else
      f:write("   "..id.."_tpCondRet ")
   end

   f:write(str_util.camel_case(fn.nome).."( ")
   if (not fn.parametros) or (#fn.parametros == 0) then
      f:write("void )") -- nenhum parâmetro
   else
      -- Primeiro parâmetro sem vírgula antes
      f:write(fn.parametros[1][2].." "..fn.parametros[1][1])
      for p = 2,#fn.parametros do
         -- fn.parametros[p] = {"Nome", "tipo", "descrição"}
         f:write(" , "..fn.parametros[p][2].." "..fn.parametros[p][1])
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
      local linha = "*     $P "..j[1]..string.rep(" ", max_len - #(j[1]) + 1)
      f:write(linha)

      local desc = str_util.line_wrap_with_prefix(j[3], wrap, "* "..string.rep(" ", #linha))
      desc = "-"..desc:sub(#linha + 2,#desc)
      f:write(desc)
   end
end

-- Imprime o comentário de header de uma função
local function imprimir_func_header(f, fn, id)
-- fn = {'Nome da função', 'Descrição', Retornos, Parâmetros, Privada}
   f:write("/***********************************************************************\n")
   f:write("*\n")
   f:write("*  $FC Função: "..id.." "..fn.nome.."\n")
   f:write("*\n")
   f:write("*  $ED Descrição da função\n")
   f:write(str_util.line_wrap_with_prefix(fn.descricao, 65, "*     "))
   f:write("*\n")
   if fn.parametros and #fn.parametros > 0 then
      f:write("*  $EP Parâmetros\n")
      imprimir_desc_params(f, fn.parametros, 72)
      f:write("*\n")
   end
   f:write("*  $FV Valor retornado\n")
   if type(fn.retornos) == 'table' then
      for j,ret in ipairs(fn.retornos) do
         f:write("*     "..id.."_CondRet"..ret.."\n")
      end
   else
      f:write("*     "..fn.retornos.." - \n")
   end
   f:write("*\n")
   f:write("***********************************************************************/\n")
   f:write("\n")
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
      if not fn.privada then -- não é privada
         imprimir_func_header(f, fn, id)
         imprimir_prototipo(f, fn, id)
         f:write(" ;\n")
         f:write("\n")
      end
   end

   f:write("\n")
   f:write("#undef "..define.."_\n")
   f:write("\n")
   f:write("/********** Fim do módulo de definição: Módulo "..params.nome.." **********/\n")
   f:write("\n")
   f:write("#else\n")
   f:write("#endif\n")

   f:flush()
   f:close()
end

-- Retorna uma tabela com as funções privadas do módulo
local function funcoes_privadas()
   local t = {}
   local i,fn
   for i,fn in ipairs(params.funcoes) do
      if fn.privada == true then
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
      imprimir_prototipo(f, fn, params.id)
      f:write(" ;\n")
      f:write("\n")
   end

   f:write("\n")
   f:write("/*****  Código das funções exportadas pelo módulo  *****/\n")
   f:write("\n")
   f:write("\n")

   for i,fn in ipairs(params.funcoes) do
      -- fn = {'Nome da função', 'Descrição', Retornos, Parâmetros, Privada}
      if fn.privada ~= true then
         f:write("/***************************************************************************\n")
         f:write("*\n")
         f:write("*  Função: "..params.id.." "..fn.nome.."\n")
         f:write("*  ****/\n");
         f:write("\n");
         imprimir_prototipo(f, fn, params.id)
         f:write("\n");
         f:write("   {\n");
         f:write("\n");
         f:write("   } /* Fim função: "..params.id.." "..fn.nome.." */\n");
         f:write("\n");
         f:write("\n");
      end
   end

   f:write("/*****  Código das funções encapsuladas pelo módulo  *****/\n")
   f:write("\n");
   f:write("\n");

   for i,fn in ipairs(func_p) do
      -- fn = {'Nome da função', 'Descrição', Retornos, Parâmetros, Privada}
      imprimir_func_header(f, fn, params.id)
      imprimir_prototipo(f, fn, params.id)
      f:write("\n");
      f:write("   {\n");
      f:write("\n");
      f:write("   } /* Fim função: "..params.id.." "..fn.nome.." */\n");
      f:write("\n");
      f:write("\n");
   end



   f:write("/********** Fim do módulo de implementação: Módulo "..params.nome.." **********/\n")
   f:write("\n")
   f:flush()
   f:close()
end

-- converte um tipo de C para uma string formatada
local function tipo_to_string(tipo)
   local ret = string.lower(tipo:gsub(" ",""))
   local conv = {}

   conv["char"]    = "char"
   conv["char*"]   = "string"
   conv["default"] = "int"

   if conv[ret] then
      return conv[ret]
   else
      return conv["default"]
   end
end

-- Params: função
-- Retorno: string com todos os tipos dos parâmetros
local function params_teste_to_string(fn)
   local fparams = {}
   local ret = "<"

   if fn.parametros then
      for i,p in ipairs(fn.parametros) do
         if not p[4] then -- não é oculto do teste
            table.insert(fparams, p)
         end
      end
   end

   if params.mult_instan then
      if #fparams > 0 then
         ret = "<int, "
      else
         ret = "<int"
      end
   end

   if #fparams > 0 then
      ret = ret .. tipo_to_string(fparams[1][2])
   end

   local p
   for p = 2,#fparams do
      ret = ret .. ", "..tipo_to_string(fparams[p][2])
   end

   -- Caso não tenha nenhum parâmetro, não retornar "<>"
   if ret == "<" then
      return nil
   end

   ret = ret .. ">"

   return ret
end

local function criar_test()
   local f = f_test
   local id = "T"..params.id
   local limite = 75

   f:write("/***************************************************************************\n")
   f:write("*  $MCI Módulo de implementação: Módulo de teste específico\n")
   f:write("*\n")
   f:write("*  Arquivo gerado:              "..params.arq_test.."\n")
   f:write("*  Letras identificadoras:      "..id.."\n")
   f:write("*\n")
   f:write("*  Projeto: Disciplina INF 1301\n")
   f:write("*  Autores:\n")
   f:write("*\n")
   f:write("*\n")
   f:write("*  $HA Histórico de evolução:\n")
   f:write("*     Versão  Autor    Data     Observações\n")
   f:write("*       1.00  ???    "..os.date("%d/%m/%Y").." Início do desenvolvimento\n")
   f:write("*\n")
   f:write("*  $ED Descrição do módulo\n")
   f:write("*     Este módulo contém as funções específicas para o teste do\n")
   f:write("*     módulo "..params.nome..".\n")
   f:write("*\n")
   f:write("*  $EIU Interface com o usuário\n")
   f:write("*     Comandos de teste específicos para testar o módulo "..params.nome..":\n")
   f:write("*\n")

   local i,fn
   for i,fn in ipairs(params.funcoes) do
      if not fn.privada then
         -- Descrição da função
         local linha = "*     ="..fn.nome_teste
         local str_params = params_teste_to_string(fn)
         if str_params then
            linha = linha.." "..str_params
         end

         f:write(linha)
         f:write(" - chama a função "..params.id.."_"..str_util.camel_case(fn.nome).."( )\n")

         -- Imprime os parâmetros
         local prefixo = "*         "
         if str_params then
            f:write(prefixo.."Parâmetros:\n")
         end

         local id = 1
         if params.mult_instan then
            f:write(prefixo.."1 - Instância: Instância do módulo a ser testada\n")
            id = 2
         end

         -- Lista os parâmetros
         for i,p in ipairs(fn.parametros) do
            if not p[4] then
               linha = tostring(id)

               linha = linha.." - "..p[1]..": "
               f:write(prefixo..linha)

               local desc -- descrição
               desc = str_util.line_wrap_with_prefix(p[3], limite - #linha - #prefixo,
               prefixo..string.rep(" ", #linha))
               desc = desc:sub(#linha + #prefixo + 1, #desc)
               f:write(desc)
               id = id + 1
            end
         end

         f:write("*\n")
      end
   end

   f:write("***************************************************************************/\n")
   f:write("\n")
   f:write("#include <stdio.h>\n")
   f:write("#include <stdlib.h>\n")
   f:write("#include <string.h>\n")
   f:write("#include <assert.h>\n")
   f:write("#include \"tst_espc.h\"\n")
   f:write("#include \"generico.h\"\n")
   f:write("#include \"lerparam.h\"\n")
   f:write("#include \""..params.arq_head.."\"\n")
   f:write("\n")
   f:write("/* Tabela os nomes dos comandos de teste específicos */\n")
   f:write("\n")

   local maior = 0
   local const
   -- encontra o maior nome e gera os símbolos
   for i,fn in ipairs(params.funcoes) do
      if not fn.privada then
         const = str_util.remove_acentos(fn.nome)
         const = const:gsub(" ", "_")
         const = "CMD_"..string.upper(const)
         fn.nome_const = const

         if maior < #const then
            maior = #const
         end
      end
   end

   -- imprime as constantes
   for i,fn in ipairs(params.funcoes) do
      if not fn.privada then
         f:write("const char "..fn.nome_const..string.rep(" ", maior - #fn.nome_const).." [] = \"=")
         f:write(fn.nome_teste.."\" ;\n")
      end
   end

   f:write("\n")
   f:write("\n")


   f:flush()
   f:close()
end

-- Parâmetros:
-- nome: Nome do módulo
-- id: Nome abreviado / prefixo / namespace do módulo
-- testes: Se true, também será gerado um arquivo de teste (.c) e um script (.script) para o arcabouço
-- mult_instan: Se true, serão utilizadas múltiplas instâncias desse módulo nos testes
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
--          - Nome Teste: String que será o nome usado no script de teste para chamar essa função.
--                        Se nil, a função é declarada como static, o namespace é omitido, o protótipo é
--                        colocado no início do .c e a função é omitida do .h e dos testes.
-- autores: Lista com o(s) nome(s) do(s) autor(es)
-- arq_code: Nome do arquivo .c do módulo.
-- arq_head: Nome do arquivo .h do módulo.
-- arq_test: Nome do arquivo .c de teste.
-- arq_script: Nome do arquivo de script de teste.
function criar_modulo(nome, id, testes, mult_instan, cond_ret, funcoes, autores, arq_code, arq_head, arq_test, arq_script)
   params.nome = nome
   params.id = string.upper(id)
   params.cond_ret = cond_ret
   params.funcoes = funcoes
   params.testes = testes
   params.mult_instan = mult_instan
   params.autores = autores
   params.arq_code = arq_code
   params.arq_head = arq_head
   params.arq_test = arq_test
   params.arq_script = arq_script

   if not abrir_arquivos() then
      return
   end

   local i,fn
   for i,fn in ipairs(funcoes) do
      if not fn.nome then
         fn.nome = fn[1]
      end

      if not fn.descricao then
         fn.descricao = fn[2]
      end

      if not fn.retornos then
         fn.retornos = fn[3]
      end

      if not fn.parametros then
         fn.parametros = fn[4]
      end

      if not fn.privada then
         if not fn[5] then
            fn.privada = true
         end
      end

      if not fn.nome_teste then
         fn.nome_teste = fn[5]
      end
   end

   criar_header()
   criar_code()
   criar_test()
end


return mod
