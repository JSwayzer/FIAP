CREATE OR REPLACE FUNCTION lib_mec_prontuario_swap()
  RETURNS varchar AS
$BODY$
DECLARE
   VL_ID_UNIDADE_SAUDE  integer;
   VL_ID_PRONTUARIO     integer;
   VL_ID_PASSAGEM       integer;
   VL_ID_LEITO          integer;
   VL_RS_01             RECORD;
   VL_SQL_01            varchar;
BEGIN
   -- Query trazendo todos os pacientes SWAP
   VL_SQL_01 = ' select 
                        t1.cd_prontuario_wpd,
                        t1.paciente,
                        t1.sexo,
                        t1.dt_nascimento,
                        t1.fone_responsavel,
                        t1.celular,
                        t1.email_paciente,
                        t1.rua,
                        t1.numero_casa,
                        t1.complemento,
                        t1.bairro,
                        t1.cidade,
                        t1.uf_estado,
                        t1.cep,
                        t1.pass_nome_responsavel,
                        t1.pass_cd_passagem_wpd,
                        t1.pass_data_entrada,
                        t1.pass_hora_entrada,
                        t1.pass_data_saida,
                        t1.pass_hora_saida,
                        t1.historico_leito,
                        t1.historico_id_reg,
                        t1.historico_cod_passagem_wpd,
                        t1.pass_tipo_paciente,
                        initcap(t1.pass_especialidade) as pass_especialidade
                   from mec_prontuario_swap t1                                       
               ';                                               

   -- Iniciando o loop no SQL
   FOR VL_RS_01 IN EXECUTE VL_SQL_01  
   LOOP

               VL_ID_UNIDADE_SAUDE = NULL;
       SELECT id_unidade_saude_end 
         INTO VL_ID_UNIDADE_SAUDE
         FROM public.mec_unidade_saude_end
 --       WHERE coalesce(cep,'') = coalesce(VL_RS_01.cep,'');
         WHERE cep = VL_RS_01.cep;


          -- PEP_PACIENTE
       VL_ID_PRONTUARIO = NULL;
       SELECT id_prontuario 
         INTO VL_ID_PRONTUARIO
         FROM public.mec_prontuario
 --       WHERE coalesce(cd_prontuario_wpd,'') = coalesce(VL_RS_01.cd_prontuario_wpd,'');
         WHERE cd_prontuario_wpd = VL_RS_01.cd_prontuario_wpd;
       IF coalesce(VL_ID_PRONTUARIO,0) = 0 AND 
          coalesce(VL_RS_01.cd_prontuario_wpd,'') <> '' THEN
          VL_ID_PRONTUARIO = nextval('mec_prontuario_id_prontuario_seq');
          INSERT INTO public.mec_prontuario
                 ( id_prontuario,
                   data_inclusao,
                   id_unidade_saude_end,
                   cd_prontuario_wpd,
                   paciente,
                   sexo,
                   dt_nascimento,
                   celular,
                   email_paciente,
                   nome_responsavel,
                   fone_responsavel,
                   rua,
                   numero_casa,
                   complemento,
                   bairro,
                   cidade,
                   uf_estado,
                   cep
                  )
          VALUES ( VL_ID_PRONTUARIO,
                   now(),
                   VL_ID_UNIDADE_SAUDE,
                   VL_RS_01.cd_prontuario_wpd,
                   VL_RS_01.paciente,
                   VL_RS_01.sexo,
                   VL_RS_01.dt_nascimento,
                   VL_RS_01.celular,
                   VL_RS_01.email_paciente,
                   VL_RS_01.pass_nome_responsavel,
                   VL_RS_01.fone_responsavel,
                   VL_RS_01.rua,
                   VL_RS_01.numero_casa,
                   VL_RS_01.complemento,
                   VL_RS_01.bairro,
                   VL_RS_01.cidade,
                   VL_RS_01.uf_estado,
                   VL_RS_01.cep

                 );
       ELSE -- Se o paciente existir, vamos atualizar
          UPDATE public.mec_prontuario
             SET data_alteracao        = now(),
                  id_unidade_saude_end = VL_ID_UNIDADE_SAUDE,
                  cd_prontuario_wpd    = VL_RS_01.cd_prontuario_wpd,
                  paciente             = VL_RS_01.paciente,
                  sexo                 = VL_RS_01.sexo,
                  dt_nascimento        = VL_RS_01.dt_nascimento,
                  celular              = VL_RS_01.celular,
                  email_paciente       = VL_RS_01.email_paciente,
                  nome_responsavel     = VL_RS_01.pass_nome_responsavel,
                  fone_responsavel     = VL_RS_01.fone_responsavel,
                  rua                  = VL_RS_01.rua,
                  numero_casa          = VL_RS_01.numero_casa,
                  complemento          = VL_RS_01.complemento,
                  bairro               = VL_RS_01.bairro,
                  cidade               = VL_RS_01.cidade,
                  uf_estado            = VL_RS_01.uf_estado,
                  cep                  = VL_RS_01.cep
           WHERE id_prontuario         = VL_ID_PRONTUARIO
             AND (coalesce(cd_prontuario_wpd, '') <> coalesce(VL_RS_01.cd_prontuario_wpd, '')
              OR  coalesce(paciente, '')         <> coalesce(VL_RS_01.paciente, '')
              OR  coalesce(sexo, '')             <> coalesce(VL_RS_01.sexo, '')
              OR  coalesce(dt_nascimento,'1900-01-01 00:00:00'::timestamp)   <> coalesce(VL_RS_01.dt_nascimento,'1900-01-01 00:00:00'::timestamp)
              OR  coalesce(celular, '')          <> coalesce(VL_RS_01.celular, '')
              OR  coalesce(email_paciente, '')   <> coalesce(VL_RS_01.email_paciente, '')
              OR  coalesce(nome_responsavel, '') <> coalesce(VL_RS_01.pass_nome_responsavel, '')
              OR  coalesce(fone_responsavel, '') <> coalesce(VL_RS_01.fone_responsavel, '')
              OR  coalesce(rua, '')              <> coalesce(VL_RS_01.rua, '')
              OR  coalesce(numero_casa, '')      <> coalesce(VL_RS_01.numero_casa, '')
              OR  coalesce(complemento, '')      <> coalesce(VL_RS_01.complemento, '')
              OR  coalesce(bairro, '')           <> coalesce(VL_RS_01.bairro, '')
              OR  coalesce(cidade, '')           <> coalesce(VL_RS_01.cidade, '')
              OR  coalesce(uf_estado, '')        <> coalesce(VL_RS_01.uf_estado, '')
              OR  coalesce(cep, '')              <> coalesce(VL_RS_01.cep, ''));
       END IF;
       --raise notice 'VL_ID_PRONTUARIO(%)',VL_ID_PRONTUARIO ;

          -- MEC_PASSAGEM
       VL_ID_PASSAGEM = NULL;
       SELECT id_passagem 
         INTO VL_ID_PASSAGEM
         FROM public.mec_passagem
        WHERE cd_passagem_wpd = VL_RS_01.pass_cd_passagem_wpd;
        --raise notice 'VL_ID_PASSAGEM(%), coalesce(%)',VL_ID_PASSAGEM, coalesce(VL_RS_01.registro,'') ;
       IF coalesce(VL_ID_PASSAGEM,0) = 0 AND 
          coalesce(VL_RS_01.pass_cd_passagem_wpd,'') <> '' THEN -- Se o registro não existir, vamos inserir
          --pegando o próximo ID utilizando a sequence
          VL_ID_PASSAGEM = nextval('mec_passagem_id_passagem_seq');
          INSERT INTO public.mec_passagem
                  (   id_passagem,
                      data_inclusao,
                      id_prontuario,
                      cd_passagem_wpd,
                      data_entrada,
                      hora_entrada,
                      data_saida,
                      hora_saida,
                      tipo_paciente,
                      especialidade
                    )
          VALUES (    VL_ID_PASSAGEM,
                      now(),
                      VL_ID_PRONTUARIO,
                      VL_RS_01.pass_cd_passagem_wpd,
                      VL_RS_01.pass_data_entrada,
                      VL_RS_01.pass_hora_entrada,
                      VL_RS_01.pass_data_saida,
                      VL_RS_01.pass_hora_saida,
                      VL_RS_01.pass_tipo_paciente,
                      VL_RS_01.pass_especialidade
                    );

       ELSE -- Se o registro existir, vamos atualizar
          UPDATE public.mec_passagem
             SET data_alteracao    = now(),
                 id_prontuario     = VL_ID_PRONTUARIO,
                 cd_passagem_wpd   = VL_RS_01.pass_cd_passagem_wpd,
                 data_entrada      = VL_RS_01.pass_data_entrada,
                 hora_entrada      = VL_RS_01.pass_hora_entrada,
                 data_saida        = VL_RS_01.pass_data_saida,
                 hora_saida        = VL_RS_01.pass_hora_saida,
                 tipo_paciente     = VL_RS_01.pass_tipo_paciente,
                 especialidade     = VL_RS_01.pass_especialidade
           WHERE id_passagem       = VL_ID_PASSAGEM
             AND ( coalesce(cd_passagem_wpd,'')                            <> coalesce(VL_RS_01.pass_cd_passagem_wpd,'')
               OR  coalesce(data_entrada,'1900-01-01 00:00:00'::timestamp) <> coalesce(VL_RS_01.pass_data_entrada,'1900-01-01 00:00:00'::timestamp)
               OR  coalesce(hora_entrada,'1900-01-01 00:00:00'::timestamp) <> coalesce(VL_RS_01.pass_hora_entrada,'1900-01-01 00:00:00'::timestamp)
               OR  coalesce(data_saida,'1900-01-01 00:00:00'::timestamp)   <> coalesce(VL_RS_01.pass_data_saida,'1900-01-01 00:00:00'::timestamp)
               OR  coalesce(hora_saida,'1900-01-01 00:00:00'::timestamp)   <> coalesce(VL_RS_01.pass_hora_saida,'1900-01-01 00:00:00'::timestamp)
               OR  coalesce(tipo_paciente,'')                              <> coalesce(VL_RS_01.pass_tipo_paciente,'')
               OR  coalesce(especialidade,'')                              <> coalesce(VL_RS_01.pass_especialidade,''));
       END IF;



       -- mec_leito
       VL_ID_LEITO = NULL;
       SELECT id_leito 
         INTO VL_ID_LEITO
         FROM public.mec_leito
        WHERE id_reg = VL_RS_01.historico_id_reg;
       IF coalesce(VL_ID_LEITO,0) = 0 AND 
          coalesce(VL_RS_01.historico_id_reg,'') <> '' THEN -- Se a ala clinica não existir, vamos inserir
          --pegando o próximo ID utilizando a sequence
          VL_ID_LEITO = nextval('mec_leito_id_leito_seq');
          INSERT INTO public.mec_leito
                 ( id_leito, 
                   data_inclusao,
                   id_reg,
                   id_passagem,
                   leito
                 )
          VALUES ( VL_ID_LEITO,
                   now(), 
                   VL_RS_01.historico_id_reg,
                   VL_ID_PASSAGEM,
                   VL_RS_01.historico_leito
                 );
       ELSE -- Se a ala_clinica existir, vamos atualizar
          UPDATE public.mec_leito 
             SET data_alteracao  = now(),
                 id_reg = VL_RS_01.historico_id_reg,
                 id_passagem = VL_ID_PASSAGEM,
                 leito = VL_RS_01.historico_leito
           WHERE id_leito = VL_ID_LEITO
             AND (coalesce(id_reg, '') <> coalesce(VL_RS_01.historico_id_reg, '')
              OR coalesce(leito, '')   <> coalesce(VL_RS_01.historico_leito, ''));
       END IF;
       --raise notice 'VL_ID_LEITO(%)',VL_ID_LEITO ;

    END LOOP;

   --*** O código abaixo deverá ser ativado para excluir a tabela SWAP

   --Excluindo a tabela pep_registro_swap
   truncate table mec_prontuario_swap;

   --Restartando a sequence para iniciar o ID com 1
   ALTER SEQUENCE public.mec_prontuario_swap_id_prontuario_swap_seq
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

