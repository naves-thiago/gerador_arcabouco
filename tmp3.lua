m=require("modulo")

-- Códigos de retorno possíveis para o arcabou
--ret= {"Nome", 'Descrição'}
ret = {{"OK", "Rodou OK"},
       {"E1", "Erro 1"},
       {"E2", "Erro 2"}}


desc = "le descrição gigantesca para poder testar o line wrap e alinhamento na hora de imprimir os parâmetros no módulo de teste"
--func {'Nome da função', 'Descrição',                    Retornos,     Parâmetros,                                       Nome Teste}
func = {{"uma função",    "Descrição boladda da função!", {"OK", "E2"}, {{"p1", "int", "le param"}, {"p2", "int", desc}}, "umafunc"},
        {"func privada",  "Função privada...",            "int",        {{"param", "char *", "parâmetro"}}                         },
        {"mais uma func", "Teste",                        "char *",     {{"p", "char *", "param"}},                       "func"   }}

--criar_modulo(nome,                id,    testes, mult_instâncias, cond_ret, funcoes, arq_code,   arq_head,   arq_test,    arq_script)
m.criar_modulo("le awesome módulo", "MOD", true,   true,            ret,      func,    "modulo.c", "modulo.h", "testmod.c", "TesteModulo.script")
