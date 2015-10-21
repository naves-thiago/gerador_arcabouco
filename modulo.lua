-- Gerador de módulos para programação modular

local str_util = require("str_util")
local io = io
local os = os
local string = string
local print = print
local ipairs = ipairs
local pairs = pairs
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
      f:write("*     Versão  Autor  Data       Observações\n")
   else
      f:write("*     Versão  Autor"..string.rep(" ", #aut -4).."  Data       Observações\n")
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

   if fn.privada then
      f:write(str_util.camel_case(fn.nome).."( ")
   else
      f:write(id.."_"..str_util.camel_case(fn.nome).."( ")
   end

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
   local define = string.upper(string.gsub(nome, " ","_"))

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
   local ret = string.lower(string.gsub(tipo," ",""))
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

local tipos_params
local function lista_tipos()
   -- global tipos_params guarda a lista de tipos para evitar recriar a lista
   if not tipos_params then
      local tipos = {} -- lista de tipos convertidos no formato 'tipo' = true

      local i,f,j,p
      for i,f in pairs(params.funcoes) do
         if not f.privada and f.parametros then
            for j,p in pairs(f.parametros) do
               tipos[ tipo_to_string(p[2]) ] = true
            end
         end
      end

      tipos["int"] = true -- Sempre deve ter o int para a condição de retorno

      tipos_params = {}
      for i,j in pairs(tipos) do
         table.insert(tipos_params, i)
      end
   end

   return tipos_params
end

-- Params: f - arquivo
local function imprimir_macros_typecast(f)
   -- TODO tratar o caso do tipo string
   local i, t
   local tipos = lista_tipos()
   for i, t in ipairs(tipos) do
      f:write("#define PARAM_"..string.upper(t).."( p ) ( *( "..t.." * ) &Parametros[ p ] )\n")
   end
end

-- Params: f - arquivo
local function imprimir_vetor_comandos(f)
   -- TODO tratar o caso do tipo string?
   f:write("static tpComandoTeste Comandos[] = {\n")
   f:write("/*   Comando             Parâmetros  Função               Mensagem de erro */\n")

   local cc = {} -- camel case
   local sc = {} -- snake case
   local p = {}
   local i,j,fn,tp
   for i, fn in ipairs(params.funcoes) do
      cc[i] = str_util.camel_case(fn.nome) .. " ,"
      sc[i] = string.gsub(str_util.remove_acentos(fn.nome), " ", "_") .. " ,"
   end

   cc = str_util.right_padding_i(cc)
   sc = str_util.right_padding_i(sc)

   for i, fn in ipairs(params.funcoes) do
          p[i] = '"'
          if fn.parametros then
             for j, tp in ipairs(fn.parametros) do
                p[i] = p[i] .. tipo_to_string(tp[2]):sub(1,1)
             end
          end
          p[i] = p[i] .. 'i"'
   end

   p = str_util.right_padding_i(p)

   for i, fn in ipairs(params.funcoes) do
       if not fn.privada then
          if i ~= #params.funcoes then
             f:write("   { CMD_"..string.upper(sc[i]).." "..p[i].." , T"..params.id.."_Cmd"..cc[i]..' "Retorno errado ao " } ,\n')
          else
             f:write("   { CMD_"..string.upper(sc[i]).." "..p[i].." , T"..params.id.."_Cmd"..cc[i]..' "Retorno errado ao " }\n')
          end
       end
   end

   f:write("} ;\n")
end

local function obter_max_params()
   local i, fn
   local max = 0
   for i, fn in ipairs(params.funcoes) do
      if #fn.parametros > max then
         max = #fn.parametros
      end
   end

   return max
end

-- Params: f - arquivo
local function imprimir_union_tipos(f)
   -- TODO tratar o caso do tipo string
   local i, t
   local tipos = lista_tipos()

   f:write("typedef union\n")
   f:write("{\n")

   for t=1, #tipos -1 do
      f:write("   "..tipos[t].." "..tipos[t]:sub(1,1).." ,\n")
   end
   f:write("   "..tipos[#tipos].." "..tipos[#tipos]:sub(1,1).."\n")
   f:write("} tpParam ;\n")
end

-- Params: fn - função a ser chamada
local function chamada_funcao_modulo(fn)
   local out = params.id .. "_"..str_util.camel_case(fn.nome).."("
   local tipos = lista_tipos()
   if params.mult_instan then
      out = out .. " Instancias[ "

      if #tipos > 1 then
         out = out .. "PARAM_INT( 0 )"
      else
         out = out .. "Parametros[ 0 ]"
      end

      out = out .. " ] "

      if #fn.parametros > 1 then
         out = out .. ","
      end
   end

   if fn.parametros then
      local i, p
      for i, p in ipairs(fn.parametros) do
         if (not params.mult_instan) or (i > 1) then -- Pula o primeiro se tiver múltiplas instâncias
            if #tipos > 1 then
               out = out.." PARAM_"..string.upper(tipo_to_string(p[2])).."( "..(i-1).." ) "
            else
               out = out.." Parametros[ "..(i-1).." ] "
            end

            if i < #fn.parametros then
               out = out .. ","
            end
         end
      end
   end

   return out .. ")"
end

local function criar_test()
   local autores = params.autores or {}
   local aut = "???"

   if autores[1] then
      aut = iniciais_autor(autores[1])
      local i
      for i=2, #autores do
         aut = aut .. ", " .. iniciais_autor(autores[i])
      end
   end

   local f = f_test
   local id = "T"..params.id
   local limite = 75
   local tipos = lista_tipos()

   f:write("/***************************************************************************\n")
   f:write("*  $MCI Módulo de implementação: Módulo de teste específico\n")
   f:write("*\n")
   f:write("*  Arquivo gerado:              "..params.arq_test.."\n")
   f:write("*  Letras identificadoras:      "..id.."\n")
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

         -- Lista os parâmetros
         if fn.parametros then
            local id = 1
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
   f:write("#include \"lerparm.h\"\n")
   f:write("#include \""..params.arq_head.."\"\n")
   f:write("\n")
   f:write("/* Nomes dos comandos de teste específicos */\n")

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
   f:write("/***** Definições utilizados neste módulo de teste *****/\n")
   f:write("\n")
   f:write("\n")

   if params.mult_instan then
      f:write("/* Quantidade máxima de instâncias do módulo que podem ser testadas\n")
         f:write(" * simultaneamente */\n")
      f:write("#define QTD_INSTANCIAS 10\n")
      f:write("\n")
   end

   f:write("/* Quantidade máxima de parâmetros permitidos em um comando de teste,\n")
   f:write(" * mais 1 para o retorno esperado */\n")
   f:write("#define MAX_PARAMS "..(obter_max_params()+1).."\n")
   f:write("\n")

   if #tipos > 1 then
      f:write("/* Macros de typecast dos parâmetros */\n")
      imprimir_macros_typecast(f)
      f:write("\n")
   end

   f:write("\n")
   f:write("/***** Tipos de dados utilizados neste módulo de teste *****/\n")
   f:write("\n")
   f:write("\n")

   if #tipos > 1 then
      f:write("/***********************************************************************\n")
      f:write("*\n")
      f:write("*  $TC Tipo de dados: T"..params.id.." Parâmetro de teste\n")
      f:write("*\n")
      f:write("*  $ED Descrição do tipo\n")
      f:write("*     Parâmetro ou retorno esperado recebido do script de teste.\n")
      f:write("*     Essa union cria um tipo com capacidade para conter qualquer um\n")
      f:write("*     dos tipos de parâmetros usados nesse script.\n")
      f:write("*\n")
      f:write("***********************************************************************/\n")
      f:write("\n")
      imprimir_union_tipos(f)
      f:write("\n")
   end

   f:write("/***********************************************************************\n")
   f:write("*\n")
   f:write("*  $TC Tipo de dados: cmdFunc\n")
   f:write("*\n")
   f:write("*  $ED Descrição do tipo\n")
   f:write("*     Ponteiro para uma função de tratamento que executa o comando\n")
   f:write("*     recebido do script.\n")
   f:write("*\n")
   f:write("***********************************************************************/\n")
   f:write("\n")
   f:write("typedef int ( * cmdFunc ) ( void ) ;\n")
   f:write("\n")
   f:write("\n")
   f:write("/***********************************************************************\n")
   f:write("*\n")
   f:write("*  $TC Tipo de dados: T"..params.id.." Descritor do comando de teste\n")
   f:write("*\n")
   f:write("*  $ED Descrição do tipo\n")
   f:write("*     Descreve a associação do comando de teste com a função de\n")
   f:write("*     tratamento e os parâmetros esperados\n")
   f:write("*\n")
   f:write("***********************************************************************/\n")
   f:write("\n")
   f:write("typedef struct\n")
   f:write("{\n")
   f:write("   const char * Comando;\n")
   f:write("      /* comando de teste lido do script */\n")
   f:write("\n")
   f:write("   char * Params;\n")
   f:write("      /* lista de parâmetros que será passada para a função\n")
   f:write("       * LER_LerParametros */\n")
   f:write("\n")
   f:write("   cmdFunc Funcao;\n")
   f:write("      /* função a ser executada para tratar o comando */\n")
   f:write("\n")
   f:write("   char * MsgErro;\n")
   f:write("      /* mensagem de erro que será mostrada em caso de falha */\n")
   f:write("\n")
   f:write("} tpComandoTeste;\n")
   f:write("\n")
   f:write("\n")
   f:write("/*****  Protóripos das funções *****/\n")
   f:write("\n")

   for i,fn in ipairs(params.funcoes) do
       if not fn.privada then
          f:write("static int T"..params.id.."_Cmd"..str_util.camel_case(fn.nome).."( void ) ;\n")
       end
   end

   f:write("\n")
   f:write("\n")
   f:write("/*****  Variáveis globais à este módulo  *****/\n")
   f:write("\n")
   if params.mult_instan then
      f:write("/***************************************************************************\n")
      f:write("*\n")
      f:write("*  Vetor: Instâncias\n")
      f:write("*  Descrição: Lista de instâncias do módulo usadas nos testes\n")
      f:write("*\n")
      f:write("*  ****/\n")
      f:write("\n")
      f:write("static "..params.id.."_tpp"..str_util.camel_case(params.nome).." Instancias[ QTD_INSTANCIAS ] = { NULL } ;\n")
      f:write("\n")
      f:write("\n")
   end
   f:write("/***************************************************************************\n")
   f:write("*\n")
   f:write("*  Vetor: Parametros\n")
   f:write("*  Descrição: Vetor que armazena os parâmetros lidos de um comando no script\n")
   f:write("*  de teste, juntamente com o retorno esperado.\n")
   f:write("*\n")
   f:write("*  ****/\n")
   f:write("\n")
   if #tipos > 1 then
      f:write("static tpParam Parametros[ MAX_PARAMS ] ;\n")
   else
      f:write("static int Parametros[ MAX_PARAMS ] ;\n")
   end
   f:write("\n")
   f:write("\n")
   f:write("/***************************************************************************\n")
   f:write("*\n")
   f:write("*  Vetor: Comandos\n")
   f:write("*  Descrição: Vetor que associa os comandos de teste às funções de tratamento\n")
   f:write("*  Obs.: Incluir um 'i' no final dos parâmetros para o retorno esperado\n")
   f:write("*\n")
   f:write("*  ****/\n")
   f:write("\n")
   imprimir_vetor_comandos(f)
   f:write("\n")
   f:write("\n")

   f:write("/*****  Código das funções exportadas pelo módulo  *****/\n")
   f:write("\n")
   f:write("\n")
   f:write("/***********************************************************************\n")
   f:write("*\n")
   f:write("*  $FC Função: T"..params.id.." Efetuar operações de teste específicas\n")
   f:write("*\n")
   f:write("*  $ED Descrição da função\n")
   f:write("*     Efetua os diversos comandos de teste específicos para o módulo\n")
   f:write("*     sendo testado.\n")
   f:write("*\n")
   f:write("*  $EP Parâmetros\n")
   f:write("*     $P ComandoTeste - String contendo o comando\n")
   f:write("*\n")
   f:write("*  $FV Valor retornado\n")
   f:write("*     Ver TST_tpCondRet definido em TST_ESPC.H\n")
   f:write("*\n")
   f:write("***********************************************************************/\n")
   f:write("\n")
   f:write("   TST_tpCondRet TST_EfetuarComando( char * ComandoTeste )\n")
   f:write("   {\n")
   f:write("\n")
   f:write("      /* Obtém o número de elementos do vetor Comandos */\n")
   f:write("      static const int qtdComandos = sizeof( Comandos ) / sizeof( Comandos[0] ) ;\n")
   f:write("      int cmd ;\n")
   f:write("      int qtdParamsLidos ,\n")
   f:write("          qtdParamsEsperados ;\n")
   f:write("\n")
   f:write("      /* Encontra a função de tratamento do comando de teste */\n")
   f:write("      for ( cmd = 0 ; cmd < qtdComandos ; cmd ++ )\n")
   f:write("      {\n")
   f:write("         if ( strcmp( Comandos[ cmd ].Comando , ComandoTeste ) == 0 )\n")
   f:write("         {\n")
   f:write("            qtdParamsEsperados = strlen( Comandos[ cmd ].Params ) ;\n")
   f:write("            assert( qtdParamsEsperados <= MAX_PARAMS ) ;\n")
   f:write("\n")
   f:write("            qtdParamsLidos = LER_LerParametros( Comandos[ cmd ].Params ,\n")
   for i=0,obter_max_params()-1 do
      f:write("                                                &Parametros[ "..i.." ] ,\n")
   end
   f:write("                                                &Parametros[ "..obter_max_params().." ] ) ;\n")
   f:write("\n")
   if params.mult_instan then
      f:write("            /* Parametros[ 0 ] é o número da instância do módulo */\n")
      f:write("            if ( ( qtdParamsLidos != qtdParamsEsperados )\n")
      f:write("              || ( Parametros[ 0 ] < 0 )\n")
      f:write("              || ( Parametros[ 0 ] >= QTD_INSTANCIAS ) )\n")
   else
      f:write("            if ( qtdParamsLidos != qtdParamsEsperados )\n")
   end
   f:write("            {\n")
   f:write("               return TST_CondRetParm ;\n")
   f:write("            } /* if */\n")
   f:write("\n")
   f:write("            /* O Retorno esperado é lido como o último parâmetro */\n")
   f:write("            return TST_CompararInt( Parametros[ qtdParamsLidos - 1 ] , Comandos[ cmd ].Funcao() ,\n")
   f:write("                                    Comandos[ cmd ].MsgErro ) ;\n")
   f:write("         } /* if */\n")
   f:write("      } /* for */\n")
   f:write("\n")
   f:write("      return TST_CondRetNaoConhec ;\n")
   f:write("\n")
   f:write("   } /* Fim função: T"..params.id.." Efetuar operações de teste específicas */\n")
   f:write("\n")
   f:write("\n")
   f:write("/*****  Código das funções internas ao módulo  *****/\n")
   f:write("\n")
   f:write("\n")

   for i, fn in ipairs(params.funcoes) do
      if not fn.privada then
         f:write("/***********************************************************************\n")
         f:write("*\n")
         f:write("*  $FC Função: T"..params.id.." Comando "..fn.nome.."\n")
         f:write("*\n")
         f:write("*  $ED Descrição da função\n")
         f:write("*     Testa \n")
         f:write("*\n")
         f:write("***********************************************************************/\n")
         f:write("\n")
         f:write("   static int T"..params.id.."_Cmd"..str_util.camel_case(fn.nome).."( void )\n")
         f:write("   {\n")
         f:write("\n")
         f:write("       return "..chamada_funcao_modulo(fn).." ;\n")
         f:write("\n")
         f:write("   } /* Fim função: T"..params.id.." Comando "..fn.nome.." */\n")
         f:write("\n")
         f:write("\n")
      end
   end

   f:write("/********** Fim do módulo de implementação: Módulo de teste específico **********/\n")

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
