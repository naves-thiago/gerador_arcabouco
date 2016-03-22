m=require("modulo")

-- Códigos de retorno possíveis para o arcabouço
--ret= {"Nome", 'Descrição'}
ret = {{"OK", "Rodou OK"},
       {"E1", "Erro 1"},
       {"E2", "Erro 2"}}

-- Descrição do parâmetro p2 da função "uma função"
desc = "le descrição gigantesca para poder testar o line wrap e alinhamento na hora de imprimir os parâmetros no módulo de teste"

-- Listas de parâmetros das funções do módulo
--    Nome  Tipo             Descrição      Nome     Tipo      Descrição     Nome  Tipo   Descrição
p1 = {{"m", "MOD_tppModulo", "Instância"}, {"p1",    "int",    "le param"}, {"p2", "int", desc}} -- Parâmetros da função "uma função"
p2 = {{"m", "MOD_tppModulo", "Instância"}, {"param", "char *", "parâmetro"}}                     -- Parâmetros da função "func privada"
p3 = {{"m", "MOD_tppModulo", "Instância"}, {"p",     "char *", "param"}}                         -- Parâmetros da função "mais uma func"

-- Lista de autores do módulo
autores = {"Nome de Teste", "Outro nome ai"}

-- Lista de funções do módulo
-- Uma função sem o parâmetro Nome Teste definido é considerada privada e não recebe o prefixo com as iniciais do módulo
-- nem é colocada no .h e no test___.c
--func  {Nome da função,    Descrição,                        Retornos,     Parâmetros,    Nome Teste}
func = {{"uma função",      "Descrição boladda da função!",   {"OK", "E2"}, p1,            "umafunc"},
        {"func privada",    "Função privada...",              "int",        p2                      },
        {"mais uma func",   "Teste",                          {"OK"},       p3,            "func"   },
        {"func sem params", "Teste de função sem parâmetros"                                        }}

-- NOTA: A geração do script de testes (arquivo .script) não está implementada
--criar_modulo(nome do módulo       id,    testes, mult_instâncias, cond_ret, funcoes, autores, arq_code,   arq_head,   arq_test,    arq_script)
m.criar_modulo("módulo", "MOD", true,   true,            ret,      func,    autores, "modulo.c", "modulo.h", "testmod.c", "TesteModulo.script")
