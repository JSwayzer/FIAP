select distinct
       t1.cd_prontuario_wpd as prontuario,
       t1.paciente,
       t1.rua,
       t1.cep,
       t4.unidade_saude as UBS,
       t2.data_entrada,
       t2.data_saida
  from public.mec_prontuario t1
 inner join public.mec_passagem t2 on t1.id_prontuario = t2.id_prontuario
 inner join public.mec_unidade_saude_end t3 on t1.id_unidade_saude_end = t3.id_unidade_saude_end
  left join public.mec_unidade_saude t4 on t3.id_unidade_saude = t4.id_unidade_saude
 where t2.tipo_paciente = 'Interno'
 order by 4 desc