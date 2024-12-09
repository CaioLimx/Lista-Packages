CREATE OR REPLACE PROCEDURE excluir_estudante(p_id_estudante NUMBER) AS
BEGIN
    DELETE FROM matricula WHERE id_aluno = p_id_estudante;
    DELETE FROM aluno WHERE id_aluno = p_id_estudante;
END;

DECLARE
    CURSOR cursor_estudantes_adultos IS
        SELECT nome, data_nascimento
        FROM aluno
        WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, data_nascimento) / 12) > 18;
    
    nome_estudante aluno.nome%TYPE;
    nascimento_estudante aluno.data_nascimento%TYPE;
BEGI
    FOR registro IN cursor_estudantes_adultos LOOP
        DBMS_OUTPUT.PUT_LINE('Nome: ' || registro.nome || ', Data de Nascimento: ' || registro.data_nascimento);
    END LOOP;
END;

DECLARE
    CURSOR cursor_estudantes_por_curso(p_curso_id NUMBER) IS
        SELECT DISTINCT a.nome
        FROM aluno a
        JOIN matricula m ON a.id_aluno = m.id_aluno
        JOIN disciplina d ON m.id_disciplina = d.id_disciplina
        WHERE d.id_curso = p_curso_id;
    
    estudante_nome aluno.nome%TYPE;
BEGIN
    FOR registro IN cursor_estudantes_por_curso(2) LOOP
        DBMS_OUTPUT.PUT_LINE('Nome do Estudante: ' || registro.nome);
    END LOOP;
END;

CREATE OR REPLACE PACKAGE PACOTE_DISCIPLINA AS
    PROCEDURE registrar_disciplina(
        p_nome_disciplina VARCHAR2,
        p_descricao_disciplina CLOB,
        p_carga_horaria_disciplina NUMBER
    );
END PACOTE_DISCIPLINA;

CREATE OR REPLACE PACKAGE BODY PACOTE_DISCIPLINA AS
    PROCEDURE registrar_disciplina(
        p_nome_disciplina VARCHAR2,
        p_descricao_disciplina CLOB,
        p_carga_horaria_disciplina NUMBER
    ) IS
    BEGIN
        INSERT INTO disciplina (nome, descricao, carga_horaria)
        VALUES (p_nome_disciplina, p_descricao_disciplina, p_carga_horaria_disciplina);
        DBMS_OUTPUT.PUT_LINE('Disciplina "' || p_nome_disciplina || '" registrada com sucesso!');
    END registrar_disciplina;
END PACOTE_DISCIPLINA;

BEGIN
    PACOTE_DISCIPLINA.registrar_disciplina(
        p_nome_disciplina => 'Gerenciamento de Banco de Dados',
        p_descricao_disciplina => 'Disciplina para a introdução das utilizações de SGBDs, entendo e aplicando seus conceitos primordiais',
        p_carga_horaria_disciplina => 200
    );
END;

SELECT * FROM disciplina;

DECLARE
    CURSOR cursor_total_estudantes IS
        SELECT d.nome, COUNT(m.id_aluno) AS total_estudantes
        FROM disciplina d
        JOIN matricula m ON d.id_disciplina = m.id_disciplina
        GROUP BY d.id_disciplina, d.nome
        HAVING COUNT(m.id_aluno) > 10;
    
    nome_disciplina disciplina.nome%TYPE;
    total_estudantes NUMBER;
BEGIN
    FOR registro IN cursor_total_estudantes LOOP
        DBMS_OUTPUT.PUT_LINE('Disciplina: ' || registro.nome || ', Total de Estudantes: ' || registro.total_estudantes);
    END LOOP;
END;

DECLARE
    CURSOR cursor_idade_media(p_id_disciplina NUMBER) IS
        SELECT AVG(TRUNC(MONTHS_BETWEEN(SYSDATE, a.data_nascimento) / 12)) AS idade_media
        FROM aluno a
        JOIN matricula m ON a.id_aluno = m.id_aluno
        WHERE m.id_disciplina = p_id_disciplina;
    
    idade_media_estudantes NUMBER;
BEGIN
    FOR registro IN cursor_idade_media(1) LOOP
        DBMS_OUTPUT.PUT_LINE('Média de Idade: ' || registro.idade_media);
    END LOOP;
END;

CREATE OR REPLACE PROCEDURE listar_estudantes_disciplina(p_id_disciplina NUMBER) AS
    CURSOR cursor_lista_estudantes IS
        SELECT a.nome
        FROM aluno a
        JOIN matricula m ON a.id_aluno = m.id_aluno
        WHERE m.id_disciplina = p_id_disciplina;
    
    nome_lista_estudante aluno.nome%TYPE;
BEGIN
    FOR registro IN cursor_lista_estudantes LOOP
        DBMS_OUTPUT.PUT_LINE('Nome do Estudante: ' || registro.nome);
    END LOOP;
END;

DECLARE
    CURSOR cursor_turmas_por_professor IS
        SELECT p.nome, COUNT(t.id_turma) AS total_turmas
        FROM professor p
        JOIN turma t ON p.id_professor = t.id_professor
        GROUP BY p.id_professor, p.nome
        HAVING COUNT(t.id_turma) > 1;
    
    nome_instrutor professor.nome%TYPE;
    total_turmas_instrutor NUMBER;
BEGIN
    FOR registro IN cursor_turmas_por_professor LOOP
        DBMS_OUTPUT.PUT_LINE('Professor: ' || registro.nome || ', Total de Turmas: ' || registro.total_turmas);
    END LOOP;
END;

CREATE OR REPLACE FUNCTION contar_turmas_professor(p_id_professor NUMBER) RETURN NUMBER IS
    quantidade_turmas NUMBER;
BEGIN
    SELECT COUNT(*) INTO quantidade_turmas
    FROM turma
    WHERE id_professor = p_id_professor;
    RETURN quantidade_turmas;
END;

CREATE OR REPLACE FUNCTION obter_instrutor_disciplina(p_id_disciplina NUMBER) RETURN VARCHAR2 IS
    nome_instrutor_disciplina professor.nome%TYPE;
BEGIN
    SELECT p.nome INTO nome_instrutor_disciplina
    FROM professor p
    JOIN turma t ON p.id_professor = t.id_professor
    WHERE t.id_disciplina = p_id_disciplina;
    RETURN nome_instrutor_disciplina;
END;
