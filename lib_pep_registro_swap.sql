CREATE OR REPLACE FUNCTION lib_pep_registro_swap()
  RETURNS varchar AS
$BODY$
DECLARE
   VL_ID_REGISTRO       integer;
   VL_ID_PACIENTE       integer;
   VL_ID_ALA_CLINICA    integer;
   VL_ID_USUARIO        integer;
   VL_RS_01             RECORD;
   VL_SQL_01            varchar;
BEGIN
   -- Query trazendo todos os pacientes SWAP
   VL_SQL_01 = '   select  t1.id_registro_swap,
                           t1.codigo_registro,
                           t1.prontuario, 
                           t1.codigo_ala,
                           t1.data_registro,
                           t1.hora_registro,
                           t1.data_fim_registro,
                           t1.hora_fim_registro,
                           t1.tipo_paciente,
                           t1.matricula
                      from pep_registro_swap t1
               ';

   -- Iniciando o loop no SQL
   FOR VL_RS_01 IN EXECUTE VL_SQL_01  
   LOOP

          -- PEP_PACIENTE
       VL_ID_PACIENTE = NULL;
       SELECT id_paciente 
         INTO VL_ID_PACIENTE
         FROM pep_paciente
 --       WHERE coalesce(prontuario,'') = coalesce(VL_RS_01.prontuario,'');
         WHERE prontuario = VL_RS_01.prontuario;
       IF coalesce(VL_ID_PACIENTE,0) = 0 AND 
          coalesce(VL_RS_01.prontuario,'') <> '' THEN
          VL_ID_PACIENTE = nextval('pep_paciente_id_paciente_seq');
          INSERT INTO public.pep_paciente
                 ( id_paciente,
                   data_inclusao,
                   prontuario
                  )
          VALUES ( VL_ID_PACIENTE,
                   now(),
                   VL_RS_01.prontuario
                 );

       ELSE -- Se o paciente existir, vamos atualizar
          UPDATE public.pep_paciente
             SET data_alteracao  = now(),
                 prontuario = VL_RS_01.prontuario
           WHERE id_paciente   = VL_ID_PACIENTE
             AND coalesce(prontuario, '') <> coalesce(VL_RS_01.prontuario, '');
       END IF;
       --raise notice 'VL_ID_PACIENTE(%)',VL_ID_PACIENTE ;

       -- CAD_USUARIO
       VL_ID_USUARIO = NULL;
       SELECT id_usuario 
         INTO VL_ID_USUARIO
         FROM cad_usuario
        WHERE matricula = VL_RS_01.matricula;
       IF coalesce(VL_ID_USUARIO,0) = 0 AND 
          coalesce(VL_RS_01.matricula,'') <> '' THEN -- Se o cad_usuario não existir, vamos inserir
          --pegando o próximo ID utilizando a sequence
          VL_ID_USUARIO = nextval('cad_usuario_id_cad_usuario_seq');
          INSERT INTO public.cad_usuario
                 ( id_usuario, 
                   data_inclusao,
                   matricula
                 )
          VALUES ( VL_ID_USUARIO,
                   now(), 
                   VL_RS_01.matricula
                 );
       ELSE -- Se o cadastro_usuario existir, vamos atualizar
          UPDATE public.cad_usuario 
             SET data_alteracao  = now(),
                 matricula = VL_RS_01.matricula
           WHERE id_usuario   = VL_ID_USUARIO
             AND coalesce(matricula, '') <> coalesce(VL_RS_01.matricula, '');
       END IF;
       --raise notice 'VL_ID_USUARIO(%)',VL_ID_USUARIO ;     

       -- PEP_ALA_CLINICA
       VL_ID_ALA_CLINICA = NULL;
       SELECT id_ala_clinica 
         INTO VL_ID_ALA_CLINICA
         FROM pep_ala_clinica
        WHERE codigo_ala = VL_RS_01.codigo_ala;
       IF coalesce(VL_ID_ALA_CLINICA,0) = 0 AND 
          coalesce(VL_RS_01.codigo_ala,'') <> '' THEN -- Se a ala clinica não existir, vamos inserir
          --pegando o próximo ID utilizando a sequence
          VL_ID_ALA_CLINICA = nextval('pep_ala_clinica_id_ala_clinica_seq');
          INSERT INTO public.pep_ala_clinica
                 ( id_ala_clinica, 
                   data_inclusao,
                   codigo_ala
                 )
          VALUES ( VL_ID_ALA_CLINICA,
                   now(), 
                   VL_RS_01.codigo_ala
                 );
       ELSE -- Se a ala_clinica existir, vamos atualizar
          UPDATE public.pep_ala_clinica 
             SET data_alteracao  = now(),
                 codigo_ala = VL_RS_01.codigo_ala
           WHERE id_ala_clinica   = VL_ID_ALA_CLINICA
             AND coalesce(codigo_ala, '') <> coalesce(VL_RS_01.codigo_ala, '');
       END IF;
       --raise notice 'VL_ID_ALA_CLINICA(%)',VL_ID_ALA_CLINICA ;

          -- PEP_REGISTRO
       VL_ID_REGISTRO = NULL;
       SELECT id_registro 
         INTO VL_ID_REGISTRO
         FROM pep_registro
        WHERE codigo_registro = VL_RS_01.codigo_registro;
        --raise notice 'VL_ID_REGISTRO(%), coalesce(%)',VL_ID_REGISTRO, coalesce(VL_RS_01.registro,'') ;
       IF coalesce(VL_ID_REGISTRO,0) = 0 AND 
          coalesce(VL_RS_01.codigo_registro,'') <> '' THEN -- Se o registro não existir, vamos inserir
          --pegando o próximo ID utilizando a sequence
          VL_ID_REGISTRO = nextval('pep_registro_id_registro_seq');
          INSERT INTO public.pep_registro
                  (   id_registro,
                      data_inclusao,
                      id_paciente,
                      id_ala_clinica,
                      id_usuario,
                      codigo_registro,
                      data_registro,
                      hora_registro,
                      data_fim_registro,
                      hora_fim_registro,
                      tipo_paciente
                    )
          VALUES (    VL_ID_REGISTRO,
                      now(),
                      VL_ID_PACIENTE,
                      VL_ID_ALA_CLINICA,
                      VL_ID_USUARIO,
                      VL_RS_01.codigo_registro,
                      VL_RS_01.data_registro,
                      VL_RS_01.hora_registro,
                      VL_RS_01.data_fim_registro,
                      VL_RS_01.hora_fim_registro,
                      VL_RS_01.tipo_paciente  
                    );

       ELSE -- Se o registro existir, vamos atualizar
          UPDATE public.pep_registro
             SET data_alteracao    = now(),
                 id_paciente       = VL_ID_PACIENTE,
                 id_ala_clinica    = VL_ID_ALA_CLINICA,
                 id_usuario        = VL_ID_USUARIO,
                 codigo_registro   = VL_RS_01.codigo_registro,
                 data_registro     = VL_RS_01.data_registro,
                 hora_registro     = VL_RS_01.hora_registro,
                 data_fim_registro = VL_RS_01.data_fim_registro,
                 hora_fim_registro = VL_RS_01.hora_fim_registro,
                 tipo_paciente     = VL_RS_01.tipo_paciente
           WHERE id_registro       = VL_ID_REGISTRO
             AND ( coalesce(codigo_registro,'')                                   <> coalesce(VL_RS_01.codigo_registro,'')
               OR  coalesce(data_registro,'1900-01-01 00:00:00'::timestamp)       <> coalesce(VL_RS_01.data_registro,'1900-01-01 00:00:00'::timestamp)
               OR  coalesce(hora_registro,'1900-01-01 00:00:00'::timestamp)       <> coalesce(VL_RS_01.hora_registro,'1900-01-01 00:00:00'::timestamp)
               OR  coalesce(data_fim_registro,'1900-01-01 00:00:00'::timestamp)   <> coalesce(VL_RS_01.data_fim_registro,'1900-01-01 00:00:00'::timestamp)
               OR  coalesce(hora_fim_registro,'1900-01-01 00:00:00'::timestamp)   <> coalesce(VL_RS_01.hora_fim_registro,'1900-01-01 00:00:00'::timestamp)
               OR  coalesce(tipo_paciente,'')                                     <> coalesce(VL_RS_01.tipo_paciente,''));
       END IF;
    END LOOP;

   --*** O código abaixo deverá ser ativado para excluir a tabela SWAP

   --Excluindo a tabela pep_registro_swap
   truncate table pep_registro_swap;

   --Restartando a sequence para iniciar o ID com 1
   ALTER SEQUENCE public.pep_registro_swap_id_registro_swap_seq
                  INCREMENT 1 
                  MINVALUE 1
                  MAXVALUE 2147483647 
                  START 1
                  RESTART 1 
                  CACHE 1
                  NO CYCLE;



   RETURN 'FINALIZADO';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;