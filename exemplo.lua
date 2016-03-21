m=require("modulo")

-- Códigos de retorno possíveis para o arcabouço
--ret= {"Nome", 'Descrição'}
ret = {{"OK", "Rodou OK"},
       {"E1", "Erro 1"},
       {"E2", "Erro 2"}}

desc = "le descrição gigantesca para poder testar o line wrap e alinhamento na hora de imprimir os parâmetros no módulo de teste"

p1 = {{"m", "MOD_tppModulo", "Instância"}, {"p1", "int", "le param"}, {"p2", "int", desc}}
p2 = {{"m", "MOD_tppModulo", "Instância"}, {"param", "char *", "parâmetro"}}
p3 = {{"m", "MOD_tppModulo", "Instância"}, {"p", "char *", "param"}}

autores = {"Nome de Teste", "Outro nome ai"}

--func {'Nome da função',   'Descrição',                      Retornos,     Parâmetros,    Nome Teste}
func = {{"uma função",      "Descrição boladda da função!",   {"OK", "E2"}, p1,            "umafunc"},
        {"func privada",    "Função privada...",              "int",        p2                      },
        {"mais uma func",   "Teste",                          "char *",     p3,            "func"   },
        {"func sem params", "Teste de função sem parâmetros"                                        }}

--criar_modulo(nome,                id,    testes, mult_instâncias, cond_ret, funcoes, autores, arq_code,   arq_head,   arq_test,    arq_script)
m.criar_modulo("le awesome módulo", "MOD", true,   true,            ret,      func,    autores, "modulo.c", "modulo.h", "testmod.c", "TesteModulo.script")
