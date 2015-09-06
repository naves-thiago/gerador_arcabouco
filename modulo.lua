-- Gerador de módulos para programação modular

module(..., package.seeall)
local str_util = require("str_util")

-- Arquivos
local f_code, f_header, f_test, f_script
local params = {}

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
function criar_modulo(nome, id, cond_ret, funcoes, arq_code, arq_head, arq_test, arq_script)
   params.nome = nome
   params.id = string.upper(id)
   params.cond_ret = cond_ret
   params.funcoes = funcoes
end

-- Cria os handles dos arquivos
local function abrir_arquivos(arq_code, arq_head, arq_test, arq_script)
   f_code = io.open(arq_code, "w")
   if (f_code == nil) then
      return false
   end

   f_header = io.open(arq_header, "w")
   if (f_header == nil) then
      f_code:close()
      return false
   end

   if (arq_test) then
      f_test = io.open(arq_test, "w")
      if (f_test == nil) then
         f_code:close()
         f_header:close()
         return false
      end
   end

   if (arq_script) then
      f_script = io.open(arq_script, "w")
      if (f_script == nil) then
         f_code:close()
         f_header:close()
         f_test:close()
         return false
      end
   end

   return true
end

-- params: file, tabela, tamanho da linha
local function imprimir_params(f, t, lin_size)
   local max_len = 0

   assert(t)
   assert(col_size)

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
      f:write("*     $P "..j[1]..string.rep(" ", len - #(j[1]) + 1))
      local desc = str_util.line_wrap_with_prefix("  ", j[3], wrap)
      desc = "-"..desc:sub(2,#desc)
      f:write(desc)
   end
end


-- Cria o arquivo de header (assume f_header válido)
local function criar_header()
   local f = f_header
   local id = params.id

   f:write("#if ! defined( "..string.upper(params.nome).."_ )\n")
   f:write("#define "..string.upper(params.nome).."_ )\n")
   f:write("/***************************************************************************\n")
   f:write("*\n")
   f:write("*  $MCD Módulo de definição: Módulo "..params.nome.."\n")
   f:write("*\n")
   f:write("*  Arquivo gerado:              "..string.lower(params.nome)..".h\n")
   f:write("*  Letras identificadoras:      "..id.."\n")
   f:write("*\n")
   f:write("*  Projeto: Disciplina INF 1301\n")
   f:write("*  Autores:\n")
   f:write("*           \n")
   f:write("*\n")
   f:write("*  $HA Histórico de evolução:\n")
   f:write("*     Versão  Autor    Data     Observações\n")
   f:write("*       1.00   ???   21/08/2015 Início do desenvolvimento\n")
   f:write("*\n")
   f:write("*  $ED Descrição do módulo\n")
   f:write("*     Descrição...\n")
   f:write("*\n")
   f:write("***************************************************************************/\n")

   f:write("\n")
   f:write("/***********************************************************************\n")
   f:write("*\n")
   f:write("*  $TC Tipo de dados: "..id.." Condicoes de retorno\n")
   f:write("*\n")
   f:write("*\n")
   f:write("***********************************************************************/\n")
   f:write("\n")
   f:write("   typedef enum {\n")
   f:write("\n")

   for i,cr in ipairs(params.cond_ret) do
      f:write("      "..id.."_CondRet"..cr[1].." = "..(i-1).." ,\n")
      f:write("          /* "..cr[2].." */\n")
      f:write("\n")
   end

   f:write("   } "..id.."_tpCondRet ;\n")
   f:write("\n")
   f:write("\n")

   for i,fn in ipairs(params.funcoes) do
-- fn = {'Nome da função', 'Descrição', Retornos, Parâmetros, Privada}
      if not fn[5] then -- não é privada
         f:write("/***********************************************************************\n")
         f:write("*\n")
         f:write("  $FC Função: "..id.." "..str_util.camel_case(fn[1]).."\n")
         f:write("*\n")
         f:write("*  $ED Descrição da função\n")
         f:write(str_util.line_wrap_with_prefix(fn[2], 65, "*   "))
         f:write("*\n")
         f:write("  $EP Parâmetros\n")
         imprimir_params(f, fn[4], 72)
         f:write("*\n")
         f:write("*  $FV Valor retornado\n")



