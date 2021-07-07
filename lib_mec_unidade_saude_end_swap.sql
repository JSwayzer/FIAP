CREATE OR REPLACE FUNCTION lib_mec_unidade_saude_swap()
  RETURNS varchar AS
$BODY$
DECLARE
   VL_ID_UNIDADE_SAUDE_END  integer;
   VL_ID_UNIDADE_SAUDE  integer;
   VL_RS_01             RECORD;
   VL_SQL_01            varchar;
BEGIN
   -- Query trazendo todos os pacientes SWAP
   VL_SQL_01 = '  select
                        rua,
                        (0|| left(cep,length(cep)-2)) as cep,
                        numero,
                        endereco_complemento as complemento,
                        bairro,
                        municipio as cidade,
                        uf,
                        nome_unidade_saude
                   from mec_unidade_saude_end_swap
               ';                                               

   -- Iniciando o loop no SQL
   FOR VL_RS_01 IN EXECUTE VL_SQL_01  
   LOOP
       
       VL_ID_UNIDADE_SAUDE = NULL;
       SELECT id_unidade_saude 
         INTO VL_ID_UNIDADE_SAUDE
         FROM public.mec_unidade_saude
 --       WHERE coalesce(cep,'') = coalesce(VL_RS_01.cep,'');
         WHERE unidade_saude = VL_RS_01.nome_unidade_saude;

          -- UNIDADE_SAUDE_END 
       VL_ID_UNIDADE_SAUDE_END = NULL;
       SELECT id_unidade_saude_end 
         INTO VL_ID_UNIDADE_SAUDE_END
         FROM public.mec_unidade_saude_end
 --       WHERE coalesce(cep,'') = coalesce(VL_RS_01.cep,'');
         WHERE cep = VL_RS_01.cep;
       IF coalesce(VL_ID_UNIDADE_SAUDE_END,0) = 0 AND 
          coalesce(VL_RS_01.cep,'') <> '' THEN
          VL_ID_UNIDADE_SAUDE_END = nextval('mec_unidade_saude_end_id_unidade_saude_end_seq');
          INSERT INTO public.mec_unidade_saude_end
                 (  id_unidade_saude_end,
                    data_inclusao,
                    id_unidade_saude,
                    rua,
                    cep,
                    numero,
                    complemento,
                    bairro,
                    cidade,
                    uf,
                    unidade_saude
                  )
          VALUES ( VL_ID_UNIDADE_SAUDE_END,
                   now(),
                   VL_ID_UNIDADE_SAUDE,
                   VL_RS_01.rua,
                   VL_RS_01.cep,
                   VL_RS_01.numero,
                   VL_RS_01.complemento,
                   VL_RS_01.bairro,
                   VL_RS_01.cidade,
                   VL_RS_01.uf,
                   VL_RS_01.nome_unidade_saude
                 );
       ELSE -- Se o paciente existir, vamos atualizar
          UPDATE public.mec_unidade_saude_end
             SET
                data_alteracao  = now(),
                id_unidade_saude   = VL_ID_UNIDADE_SAUDE,
                rua             = VL_RS_01.rua,
                cep             = VL_RS_01.cep,
                numero          = VL_RS_01.numero,
                complemento     = VL_RS_01.complemento,
                bairro          = VL_RS_01.bairro,
                cidade          = VL_RS_01.cidade,
                uf              = VL_RS_01.uf,
                unidade_saude   = VL_RS_01.nome_unidade_saude
           WHERE id_unidade_saude_end           =  VL_ID_UNIDADE_SAUDE_END
             AND  (coalesce(rua, '')             <> coalesce(VL_RS_01.rua, '')
              OR  coalesce(cep, '')             <> coalesce(VL_RS_01.cep, '')
              OR  coalesce(numero, '')          <> coalesce(VL_RS_01.numero, '')
              OR  coalesce(complemento, '')     <> coalesce(VL_RS_01.complemento, '')
              OR  coalesce(bairro, '')          <> coalesce(VL_RS_01.bairro, '')
              OR  coalesce(cidade, '')          <> coalesce(VL_RS_01.cidade, '')
              OR  coalesce(uf, '')              <> coalesce(VL_RS_01.uf, '')
              OR  coalesce(unidade_saude, '')   <> coalesce(VL_RS_01.nome_unidade_saude, ''));
       END IF;
       --raise notice 'VL_ID_UNIDADE_SAUDE_END(%)',VL_ID_UNIDADE_SAUDE_END ;
    END LOOP;

   --*** O código abaixo deverá ser ativado para excluir a tabela SWAP

   --Excluindo a tabela pep_registro_swap
/*   truncate table mec_unidade_saude_end_swap;

   --Restartando a sequence para iniciar o ID com 1
   ALTER SEQUENCE public.mec_unidade_saude_end_swap_id_unidade_saude_end_swap_seq
                  INCREMENT 1 
                  MINVALUE 1
                  MAXVALUE 2147483647 
                  START 1
                  RESTART 1 
                  CACHE 1
                  NO CYCLE;

*/

   RETURN 'FINALIZADO';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;